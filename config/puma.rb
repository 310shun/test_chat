#rails_env = ENV['RAILS_ENV'] || 'production'

threads 4,4

pidfile "/tmp/puma.pid"
bind 'unix:///tmp/puma.sock'
state_path "/tmp/puma.state"
activate_control_app
