require 'singleton'

# Interface controller is responsible for managing connections and updating those connections as events are processed by thr player
class InterfaceController
	
	include Singleton
	
	attr_accessor :connections
	def connections
		@connections ||= Array.new
	end
	
	def client_connected conn
		self.connections << conn
		broadcast_message "client connected #{conn}", :exclude_connections => [conn]
	end
	
	def client_disconected conn
		self.connections.delete_if { |c| c == conn }
	end
	
	def broadcast_message message, opts = Hash.new
		opts[:exclude_connections] ||= Array.new
		
		notification = JukeboxController.instance.info
		notification[:notification] = message
		
		puts "COMM OUT (broadcast): #{notification}"
		
		self.connections.each do |conn|
			next if opts[:exclude_connections].include?(conn)
			send_data_to notification, conn
		end
	end
	
	def send_message_to message, connection
		conn = self.connections.detect { |c| c == connection }
		
		response = JukeboxController.instance.info
		response[:response] = message
		
		puts "COMM OUT: #{response}"
		send_data_to response, conn
	end
	
	
	protected
	
	def send_data_to data, connection
		puts connection
		case connection.class.to_s
		when "TcpSocketInterface"
			puts "sending to tcp"
			connection.push JSON.generate(data)
		when "EventMachine::WebSocket::Connection"
			puts "sending to websocket"
			connection.send JSON.generate(data)
		else
			puts "Umm?"
		end
	end
	
	#def send_status_to status, connectin
	#	self.connections.detect { |conn| conn == connection }.try :push, message
	#end
	
end
