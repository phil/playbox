class Vote
	
	include DataMapper::Resource
	
	property :id, Serial
	property :vote, Boolean
	
	property :created_at, DateTime
	property :updated_at, DateTime
	
	belongs_to :user
	belongs_to :track
	
end