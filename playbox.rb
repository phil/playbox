#! /usr/bin/env ruby
require 'rubygems'
puts File.expand_path("../config/environment", __FILE__)
require File.expand_path("../config/environment", __FILE__)

TCPSocketPort = 8082
WebSitePort = 8083
WebSocketPort = 8084

EventMachine.run do
	
	# TCP Socket Inerface
	EventMachine.start_server '127.0.0.1', TCPSocketPort, TcpSocketInterface do |connection|
		
	end
	
	# Sinatra Website Interface
	WebSiteInterface.run! :port => WebSitePort
	
	# Web Sokcet Interface
	EventMachine::WebSocket.start(:host => "nyx.local", :port => WebSocketPort) do |connection|

	  # Called when a browser loads/refreshes a page
	  connection.onopen {
			# InterfaceController.instance.client_connected self
	    #user_id = socket.object_id
	    #@server_bridge.connect(socket, user_id)
			InterfaceController.instance.client_connected connection
	    puts "WebSocket connection opened for #{connection} at #{Time.now}"
	  }

	  # Called when the browser client sends a message to the web socket server
	  connection.onmessage { |message|
			puts "COMM IN: onmessage #{message}"
			begin
				command = JSON.parse message
			rescue
				InterfaceController.instance.send_message_to({:action => "error", :message => "Could not understand command"}, connection)
			end
			
			case command["action"]
			when "search"
				EM.defer(lambda{
					JukeboxController.instance.send(command["action"].to_sym, command) 
				}, lambda{ |obj| 
					InterfaceController.instance.send_message_to({:action => "search", :results => []}, connection) 
				})
			when "track"
				EM.defer( lambda{
					puts "getting track #{command["track_id"]}"
					track = Track.get(command["track_id"])
					track.hashify :include_attributes => :plays
				}, lambda{ |track| 
					puts "sending track #{track}"
					InterfaceController.instance.send_message_to({:action => "track", :track => track}, connection)
				})
			else
				EM.defer do
					JukeboxController.instance.send(command["action"].to_sym, command) 
				end
			end
	  } # END onmessage

	  # Called when a browser closes/refreshes a page
	  connection.onclose {
	    #user_id = socket.object_id
	    #@server_bridge.disconnect(socket, user_id)
			InterfaceController.instance.client_disconected connection
	    puts "WebSocket connection closed for #{connection} at #{Time.now}"
	  }
	end
	
	
	# Jukebox has a polling service
	# that checks to see if the current song is still playing
	# as well as incrementing the progress etc
	EventMachine.add_periodic_timer 1 do
		JukeboxController.instance.check_status
	end
	
	EventMachine.add_periodic_timer 10 do
		puts JukeboxController.instance.info
	end
	
	# Scanner Task
	EventMachine.add_periodic_timer 1000 do
		puts "Firing Scanner"
	end

end

