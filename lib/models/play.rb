class Play
	
	include DataMapper::Resource
	
	property :id, Serial
	
	property :created_at, DateTime
	property :updated_at, DateTime
	
	property :played_at, DateTime
	
	belongs_to :user
	belongs_to :track
	
	def self.next
		Play.first :played_at => nil, :order => [:created_at.asc]
	end
	
	#def self.current
	#	
	#end
	#
	#def self.previous
	#	
	#end
	
end