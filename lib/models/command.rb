class Command 
	
	include DataMapper::Resource
	
	property :id, Serial
	property :action, String
	property :command, String
	
	property :created_at, DateTime
	property :updated_at, DateTime
	
	belongs_to :user
	
	def self.log hash
		
	end
	
end