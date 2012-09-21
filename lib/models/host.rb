class Host
	
	include DataMapper::Resource
	
	property :id, Serial
	property :name, String
	
	property :created_at, DateTime
	property :updated_at, DateTime
	
	property :online, Boolean # Used to set if the share is accessible, This is a simple way to 
	
	
	belongs_to :user
	
	has n, :tracks
	
end