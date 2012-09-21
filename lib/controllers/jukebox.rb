require 'singleton'

class JukeboxController
	
	include Singleton
	
	# State Machine 
	
	attr_accessor :skip_check
	
	attr_accessor :next_play
	attr_accessor :current_song
	#attr_accessor :current_play
	attr_accessor :progress
	
	state_machine :state, :initial => :stopped do
      #
		#before_transition :on => :stop, :do => :que_next_play # jukebox is about to stop playing track
		#after_transition  :on => :stop, :do => :play, :if => :next_play # Jukebox has stopped playing music, try and play the next track if its been qued
		
		#after_transition :stopped => :play, :do => :something
		#before_transition :on => :play, :do => :que_next_play # just in case the playlist 
		#after_transition  :on => :play, :do => :resume_progress 
		#after_transition  :on => :play, :do => :clear_que 
		
		before_transition :on => :play, :do => proc{ puts "b4 :play" }
		after_transition :on => :play, :do => proc { puts "arf :play" }
		after_transition :on => :play, :do => :clear_que
		
		#after_transition :on => :pause, :do => :pause_progress 
		
		#after_transition :on => :vote, :do => :cast_vote
		
		event :stop do
			transition any => :stopped
		end
		
		
		event :play do
			transition any => :playing
		end
		
		
		event :pause do
			transition :playing => :paused
		end
		
		event :resume do
			transition :paused => :playing
		end
		
		event :next do
			
		end
		event :previous do
			# TODO: umm errrr
		end
		
	end
	
	
	# State Override Events
	
	#def stop command = Hash.new
	#	super
	#end
	
	# Override State Machine 'play' event so we can pass in the command hash
	def play command = Hash.new
		puts "play 1"
		#return if playing?
		#self.skip_check = true
		puts "playing now"
		if self.current_song.try :paused?
			puts "its paused, so lets play"
      operation = Proc.new do
        self.current_song.try :resume
      end
      callback = Proc.new do |obj|
        InterfaceController.instance.broadcast_message({:status => "playing", :play => next_play})
      end
      EM.defer operation, callback
		else
			puts "pausing"
			self.current_song.try :pause
			
			puts "que next song"
			
			que_next_play
			#self.
			puts "lets start playing the next track"
			if self.next_play && File.exists?(self.next_play.track.file_path) #file_path
				
				sample = Gosu::Sample.new next_play.track.file_path
				
				self.current_song = nil
				self.current_song = sample.play
				self.next_play.update(:played_at => Time.now)
        EM.next_tick {
          InterfaceController.instance.broadcast_message({:status => "playing", :play => next_play})
        }
			end
			
		end
		#self.skip_check = false
		super
		
		puts "play 2"
	end
	
	def pause command = Hash.new
		#play if paused?
    operation = Proc.new do
      self.current_song.try :pause
    end
    callback = Proc.new do |obj|
      EM.next_tick {
        InterfaceController.instance.broadcast_message({:status => "paused"})
      }
    end
    EM.defer operation, callback
		super
	end
	
	def next command = Hash.new
		play
		super
		
	end
	
	def previous command = Hash.new
		super
	end
	
	# Non state events
	
	def vote command = Hash.new
		raise "Track required for voting" if command["track_id"].nil?
		raise "missing vote" if command["vote"].nil?
		super
	end
	
	def add command = Hash.new
		track = Track.get(command["track_id"])
		play = Play.new(
		  :track => track,
		  :user => User.first
		)
		
		play.save
		
		EM.defer { 
			InterfaceController.instance.broadcast_message({
			  "type" => "playlist_add", 
				"play" => play
			})
		}
	end
	
	def remove command = Hash.new
		raise "Missing play id" if command["play_id"].nil?
	end
	
	def track_info command = Hash.new
		raise "Missing track id" if command["track_id"].nil?
		track = Track.get(command["track_id"])
		track.plays
		track.votes
		track
	end
	
	
	
	
	
	def check_status
		if playing?
			self.progress ||= 0
			self.progress += 1
		end
		
		#self.skip_check = false if self.skip_check.nil?
		#return if self.skip_check
		current = current_song_state # locally assign state for speed
		if current == state
			puts "same as, keep going (#{current} : #{state})"
		else
			# something changed
			puts "weeee, changed from:#{current} to:#{state}"
			
			case current
			when "stopped"
				puts "trying stop"
				play
			when "playing"
				puts "trying play"
				#play
			when "paused"
				puts "trying pause"
				#pause
			end
			
		end
		
		
		
	end
	
	# Needs to return the same strings as the state machine
	def current_song_state
		if self.current_song && self.current_song.playing?
			"playing"
		elsif self.current_song && self.current_song.paused?
				"paused"
		else
			"stopped"
		end
	end
	
	#
	def update_state
		
	end
	
	#def play_track track, command = Hash.new
	#	pause if playing?
	#	puts "playing track? #{track.file_path}"
	#	if File.exists? track.file_path #file_path
	#		sample = Gosu::Sample.new track.file_path
	#		self.current_song = sample.play
	#		InterfaceController.instance.broadcast_status({:status => "playing", :filename => command["filename"]})
	#	end
	#	
	#end
	
	#def play command = Hash.new
	#	return if playing?
	#	if self.current_song && self.current_song.paused?
	#		self.current_song.resume
	#	else
	#		if next_play && File.exists?(next_play.track.file_path) #file_path
	#			sample = Gosu::Sample.new next_play.track.file_path
	#			self.current_song = sample.play
	#			next_play.update(:played_at => Time.now)
	#			InterfaceController.instance.broadcast_status({:status => "playing", :play => next_play})
	#		end
	#	end
	#end
  
	#def pause command = Hash.new
	#	puts "pausing"
	#	self.current_song.try :pause
	#end
	#
	#def resume command = Hash.new
	#	self.current_song.try :resume
	#end
	#
	#def next command = Hash.new
	#	self.current_song.stop
	#	self.current_song = nil
	#	self.play
	#end
	
	
	
	
	#def vote command = Hash.new
	#	raise "Track required for voting" if command["track_id"].nil?
	#	raise "missing vote" if command["vote"].nil?
	#	
	#end
	
	def info
		{
			:state => state,
			:progress => progress,
      :play => (current_play rescue nil)
		}
	end
	
	protected
	#
	#def playing?
	#	self.current_song.try :playing?
	#end
	#
	#def paused?
	#	self.current_song.try :paused?
	#end
	
	
	def que_next_play
		self.next_play ||= Play.next
	end
	def clear_que
		self.next_play = nil
	end
	
	def reset_progress
		self.progress = nil
	end
	#def pause_progress
	#	
	#end
	
	
	#attr_accessor :previous_state # playing, paused, stopped
	#
	#def current_state
	#	if playing?
	#		"playing"
	#	elsif paused?
	#		"paused"
	#	else
	#		"stopped"
	#	end
	#end
	
end
