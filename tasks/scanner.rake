require "mp3info"

namespace :scanner do
  
  desc "Runs the scanner on all files in the media folder"
  task :run => :environment do
    puts ROOT
    
    @host = nil
    @user = User.first
    
    Dir.glob("media/**/*").each_with_index do |file,idx| 
      puts ""
      
      host = file.split("/")[1]
      
        if File.directory? file
          puts "parsing Dir #{file}"
          
          if @host && @host.name == host
            puts "using host #{host}"
          else
            puts "making host #{host}"
            @host = Host.first_or_create :name => host, :user => @user
          end
          
        elsif File.file? file
          puts "parsing File #{file}"
          
          parts = file.split("/")
          parts.shift
          path = parts.join("/")
          
          track = Track.first :conditions => {:path => path}
          if track.nil?
            t = Track.new 
            t.path = path
            t.host = @host
            t.save
            
            Mp3Info.open(file) do |mp3info|
              t.artist = mp3info.tag.title
              t.album = mp3info.tag.album
              t.title = mp3info.tag.artist
              
              t.bpm = 0
              t.length = mp3info.tag.length
              t.genre = mp3info.tag.genre_s
            end
            
            t.save
            
            
            #puts t
          else
            puts "skipping #{file}"
          end
        end
    end
  end
  
end