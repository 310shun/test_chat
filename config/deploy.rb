#========================
#CONFIG
#========================
set :application, "test_chat"
set :scm, :git
set :repository, "git@github.com:asiram/test_chat.git"
set :branch, "master"
set :ssh_options, { :forward_agent => true, :port => "10022" }
set :stage, :production
set :user, "sato_shun"
set :rake, "/usr/local/rbenv/shims/rake"
# set :maintenance_basename, "maintenance"
# set :maintenance_template_path, File.join(File.dirname(__FILE__), "templates", "maintenance.erb")
set :use_sudo, true
set :runner, "deploy"
set :deploy_to, "/var/www/#{application}"
set :app_server, :puma
set :domain, "172.30.4.62"
set :rails_env, :production
set :puma_pid, "/tmp/puma.pid"
set :puma_binary, "puma"
set :puma_ctl, "pumactl"
set :puma_config, "#{current_path}/config/puma.rb"
set :puma_state, "/tmp/puma.state"
set :puma_pid, "/tmp/puma.pid"

working_directory = Dir.pwd

#directory       working_directory
#bind            "unix:///#{working_directory}/tmp/sockets/puma.sock"


#========================
#ROLES
#========================
role :app, domain
role :web, domain
role :db, domain, :primary => true
#========================
#CUSTOM
#========================
namespace :puma do
  desc "Start Puma"
  task :start, :except => { :no_release => true } do
    run "cd #{current_path} && RAILS_ENV=production #{puma_binary} -C #{puma_config} -e #{rails_env} -d"
  end
  after "deploy:start", "puma:start"

  desc "Stop Puma"
  task :stop, :except => { :no_release => true } do
    run "cd #{current_path} && kill -9 `cat #{puma_pid}` || echo 'skip' "
    run "rm /tmp/puma.sock || echo 'skip'"
  end
  after "deploy:stop", "puma:stop"

  desc "remove sock"
  task :remove_socket, :except => { :no_release => true } do
    run "cd #{current_path} && rm tmp/sockets/puma.sock"
  end

  desc "Restart Puma"
  task :restart, roles: :app, :expect => { no_release: true } do
    run "cd #{current_path} && kill -9 `cat #{puma_pid}` || echo 'skip' "
    run "rm /tmp/puma.sock || echo 'skip'"
    run "cd #{current_path} && RAILS_ENV=production #{puma_binary} -C #{puma_config} -e #{rails_env} -d || echo 'skip'"
  end
  after "deploy:restart", "puma:restart"

  desc "create a shared tmp dir for puma state files"
  task :after_symlink, roles: :app do
    run "sudo rm -rf #{release_path}/tmp"
    run "ln -s #{shared_path}/tmp #{release_path}/tmp"
  end
  after "deploy:create_symlink", "puma:after_symlink"

  desc "boot websocket"
  task :web_socket, roles: :app, :expect => { no_release: true } do
    run "sh #{current_path}/config/shell/websocket_open.sh || echo 'skip'"
  end

  desc "stop websocket"
  task :web_socket_stop, :expect => { no_release: true } do
    run "sh #{current_path}/config/shell/websocket_close.sh || echo 'skip'"
  end

  task :disable, :roles => :web, :except => { :no_release => true } do
    require 'erb'
    on_rollback { run "rm -f #{current_path}/public/system/#{maintenance_basename}.html" }

    reason = ENV['REASON']
    deadline = ENV['UNTIL']

    template = File.read(maintenance_template_path)
    result = ERB.new(template).result(binding)

    put result, "#{current_path}/public/system/#{maintenance_basename}.html", :mode => 0644
  end

  task :enable, :roles => :web, :except => { :no_release => true } do
    run "rm -f #{current_path}/public/system/#{maintenance_basename}.html"
  end
end
