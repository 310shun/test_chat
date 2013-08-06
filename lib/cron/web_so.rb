#require 'em-websocket'

#rails runner Cron::WebSo.set_web
class Cron::WebSo

  #group_idとuser_idを受け取って、ハッシュにする
  #取得できるquery_stringはstring型なので無理矢理ー
  #パラメータ：query_string(group_id=3&user_id=2 のような文字列)
  def self.get_query_string_hash(query_string)
    query_array = query_string.split("&")
    query_hash = Hash.new

    query_array.each do |query|
      key_value_array = query.split("=")
      query_hash.store(key_value_array[0], key_value_array[1])
    end

    return query_hash
  end

  def self.set_web
    @@session_id_list = Hash.new
    @@session_group_list = Hash.new
    @@session_groups = Hash.new


    EM.run {
      #connections = Array.new
      #key:sid value:websocket
      sid_list = Hash.new
      @channel = EM::Channel.new
      @sid = nil
      EM::WebSocket.run(:host => "localhost", :port => 8080) do |ws|
    ws.onopen { |handshake|
      puts "WebSocket connection open. query: #{handshake.query_string}"

      # Access properties on the EM::WebSocket::Handshake object, e.g.
      # path, query_string, origin, headers
      query_hash = self.get_query_string_hash(handshake.query_string)
      
      # Publish message to the client
      @sid = @channel.subscribe { |msg| ws.send msg }
      @@session_id_list[ws] = @sid
      @@session_group_list[@sid] = query_hash["group_id"]

      @@session_groups[query_hash["group_id"]] = Array.new unless @@session_groups[query_hash["group_id"]]
      @@session_groups[query_hash["group_id"]] << @sid

      # sid_list[ws] = @sid
      # puts "WW#{@sid}"
      #@channel.push "session_id:#{@sid}  group_id:#{query_hash[:group_id]} connected!"
      puts "session_id:#{@sid}  group_id:#{query_hash["group_id"]} connected!"
      #connections.push(ws) unless connections.index(ws)
      #ws.send "Hello Client, you connected to #{handshake.path}"
    }

    ws.onclose { 
      puts "Connection closed" 
      # my_sid = sid_list[ws]
      # WebsocketSession.where(sid: my_sid).first.destroy
    }

    ws.onmessage { |msg|
      # if msg =~ /user:/
      #   user_address = msg[5]
      #   group_id = msg[7]
      #   sid = sid_list[ws]
      #   #Todo.new.save
      #   WebsocketSession.new(address: user_address, group_id: group_id, sid: sid).save
      # else
      #   my_session = WebsocketSession.where(sid: sid_list[ws]).first
      #   group_menber_sessions = WebsocketSession.where(group_id: my_session.group_id)

        
      #   group_menber_websockets = Array.new
      #   group_menber_sessions.each do |menber_session|
      #     group_menber_websockets << sid_list.key(menber_session.sid) #sidからwsを取得
      #     #puts "sid #{menber_session.sid}"
      #   end
        
      #   #puts "debug2 #{group_menber_websockets.count}"
      #   group_menber_websockets.each do |menber_websocket|
      #     menber_websocket.send(msg)
      #   end
        
      # end
      puts "Recieved message: #{msg}"

      my_sid = @@session_id_list[ws]
      puts "$$$"
      my_group_session_ids = @@session_groups[@@session_group_list[my_sid]]
      puts "&&&"
      my_group_session_ids.each do |session_id|
        @@session_id_list.key(session_id).send msg
      end


      
      
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
