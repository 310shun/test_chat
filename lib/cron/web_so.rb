#require 'em-websocket'

#rails runner Cron::WebSo.set_web
class Cron::WebSo

  def self.set_web
    EM.run {
      #connections = Array.new
      #key:sid value:websocket
      sid_list = Hash.new
      @channel = EM::Channel.new
      @sid = nil
      EM::WebSocket.run(:host => "0.0.0.0", :port => 8080) do |ws|
    ws.onopen { |handshake|
      puts "WebSocket connection open"

      # Access properties on the EM::WebSocket::Handshake object, e.g.
      # path, query_string, origin, headers

      # Publish message to the client
      @sid = @channel.subscribe { |msg| ws.send msg }
      sid_list[ws] = @sid
      puts "WW#{@sid}"
      @channel.push "#{@sid} connected!"
      #connections.push(ws) unless connections.index(ws)
      #ws.send "Hello Client, you connected to #{handshake.path}"
    }

    ws.onclose { 
      puts "Connection closed" 
      my_sid = sid_list[ws]
      WebsocketSession.where(sid: my_sid).first.destroy
    }

    ws.onmessage { |msg|
      if msg =~ /user:/
        user_address = msg[5]
        group_id = msg[7]
        sid = sid_list[ws]
        #Todo.new.save
        WebsocketSession.new(address: user_address, group_id: group_id, sid: sid).save
      else
        my_session = WebsocketSession.where(sid: sid_list[ws]).first
        group_menber_sessions = WebsocketSession.where(group_id: my_session.group_id)

        
        group_menber_websockets = Array.new
        group_menber_sessions.each do |menber_session|
          group_menber_websockets << sid_list.key(menber_session.sid) #sidからwsを取得
          #puts "sid #{menber_session.sid}"
        end
        
        #puts "debug2 #{group_menber_websockets.count}"
        group_menber_websockets.each do |menber_websocket|
          menber_websocket.send(msg)
        end
        
      end


      
      puts "Recieved message: #{msg}"
      #@channel.push "<#{@sid}>msg"
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