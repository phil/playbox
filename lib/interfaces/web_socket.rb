module WebSocketInterface
	
end



__END__

@server_bridge = ServerBridge.new

# This Event Machine Server is setup to receive messages from our rails app
EventMachine::start_server EVENT_MACHINE_SERVER_HOST, EVENT_MACHINE_SERVER_PORT, EventMachineServer do |c|
  # Assigning the server bridge instance to this em server allows it to know the clients
  # that are connected to the web socket server & can broadcaast messages to them
  c.server_bridge = @server_bridge 
end

EventMachine::WebSocket.start(:host => WEB_SOCKET_SERVER_HOST, :port => WEB_SOCKET_SERVER_PORT) do |socket|
  
  # Called when a browser loads/refreshes a page
  socket.onopen {
    user_id = socket.object_id
    @server_bridge.connect(socket, user_id)
    puts "WebSocket connection opened for #{user_id} at #{Time.now}"
  }

  # Called when the browser client sends a message to the web socket server
  # Not currently implemented
  socket.onmessage { |message|
    puts "Received WebSocket message at #{Time.now}: #{message}"
    params = JSON message
    @server_bridge.send(params["action"], socket)
  }

  # Called when a browser closes/refreshes a page
  socket.onclose {
    user_id = socket.object_id
    @server_bridge.disconnect(socket, user_id)
    puts "WebSocket connection closed for #{user_id} at #{Time.now}"
  }
end



class ServerBridge
  
  attr_accessor :connections
  
  def initialize()
    @connections = {}  
  end
  
  def connect(socket, user_id)
    @connections[user_id] = Connection.new(socket, user_id)
    @connections[user_id].socket.send(StatusFormat.new.all)
    puts "Number of Connections: #{@connections.size}"
  end
  
  def disconnect(socket, user_id)
    @connections.delete(user_id)
  end
  
  # Any messages received by the EventMachineServer are passed on to this bridge via this broadcast method
  # This method simply sends the message on to all the clients it knows are connected to the WebSocketServer
  def broadcast(message)
    @connections.each do |user_id, connection|
      connection.socket.send(message)
    end
  end

end