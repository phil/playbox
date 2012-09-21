module TcpSocketInterface
	
	attr_accessor :current_user
	
	def post_init
		puts "Received a new connection"
		InterfaceController.instance.client_connected self
		@data_received = ""
		@line_count = 0
	end

	def receive_data data
    command = JSON.parse data
    puts "COMM IN: #{command}"
		
		EM.defer { JukeboxController.instance.send(command["action"].to_sym, command) }
  rescue
    puts "Message Failure"
	end
	
	def push message
		send_data message
	end
	
	# Connection Clsed
	def unbind
		
	end
	
end
