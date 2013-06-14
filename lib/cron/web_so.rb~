#require 'em-websocket'

class Cron::WebSo

  def self.set_web
    EM.run {
      connections = Array.new
      @channel = EM::Channel.new
      @sid = nil
      EM::WebSocket.run(:host => "0.0.0.0", :port => 8080) do |ws|
    ws.onopen { |handshake|
      puts "WebSocket connection open"

      # Access properties on the EM::WebSocket::Handshake object, e.g.
      # path, query_string, origin, headers

      # Publish message to the client
      @sid = @channel.subscribe { |msg| ws.send msg }
      puts "WW#{@sid}"
      @channel.push "#{@sid} connected!"
      #connections.push(ws) unless connections.index(ws)
      #ws.send "Hello Client, you connected to #{handshake.path}"
    }

    ws.onclose { puts "Connection closed" }

    ws.onmessage { |msg|
      puts "Recieved message: #{msg}"
      @channel.push "<#{@sid}>msg"
      #ws.send "Pong: #{msg}"

      # connections.each {|con|
      #   #to other people
      #   con.send(msg) unless con == ws
      # }

    }

    #Todo.new.save
    end
    }
  end

end