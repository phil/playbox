class Track
	
	include DataMapper::Resource
	
	property :id, Serial
	property :created_at, DateTime
	property :updated_at, DateTime
	
	property :path, String
	
	property :title, String
	property :artist, String
	property :album, String
	
	property :bpm, Integer
	
	property :length, Integer
	
	property :genre, String
	
	property :last_played_at, DateTime
	
	# Associations
	belongs_to :host
	has n, :votes
	
	has n, :plays
	
	
	def file_path
    File.join(MEDIA_FOLDER, path)
	end
	
	def hashify opts = Hash.new
		opts[:include_attributes] = [*opts[:include_attributes]] || Array.new
		h = self.attributes
		opts[:include_attributes].each do |attrib|
			h[attrib] ||= self.send(attrib).collect{|a| a.attributes}
		end
		h
	end
	
end