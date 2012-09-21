class User
	
	include DataMapper::Resource
	
	property :id, Serial
	property :created_at, DateTime
	property :updated_at, DateTime
	
	property :login, String
	property :password, String
	
	has n, :hosts
	has n, :votes
	
	has n, :plays
	has n, :commands
	
end