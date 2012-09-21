require "#{__FILE__}/../web_site/partials"
require 'sinatra/mapping'

class WebSiteInterface < Sinatra::Base
  
  extend Sinatra::Mapping
	
	set :views, File.join(ROOT, "interfaces", "web_site", "views")
	set :public_folder, File.join(ROOT, "interfaces", "web_site", "public")
	set :static, true
	
	#map :playlist, "/"
	#map :playlist_add_track, "/playlist/add/:track_id"
	#map :playlist_remvoe_play, "/playlist/remove/play_id"
	
	#map :library, "/library"
	
	#mapping :playlist => 
	
	#helpers 
	helpers do 
	  include Sinatra::Partials 
	  include Sinatra::Mapping::Helpers
  end
	
	get "/" do
		puts "Index reload"
	  @tracks = Track.all
	  @plays = (Play.all(:created_at.gte => Date.today, :order => [:created_at.asc]) + Play.all(:played_at => nil, :order => [:created_at.asc]))
		erb :playlist
	end
	
	get "/dashboard" do
	  
	end
	
	get "/profile" do
	
	end
	
	get "/library" do
  end
  get "/search" do
  end
  
  get "/playlist/add/:track_id" do
    command = {"action" => "add", "track_id" => params[:track_id]}
    EM.defer do
      JukeboxController.instance.send :add, command
    end
    redirect to("/")
  end
  post "/playlist/remove/:play_id" do
  end
  
  
  get "/play_track/:track_id" do
    
    track_id = params[:track_id]
    
    EM.defer do 
      JukeboxController.instance.send :play_track, Track.get(track_id)
    end
    
    redirect to(playlist_path)
  end
  
	get "/play" do
		EM.defer { JukeboxController.instance.send :play }
		redirect to("/")
	end
  get "/pause" do
    EM.defer { JukeboxController.instance.send :pause }
    redirect to('/')
	end
	get "/resume" do
	  EM.defer { JukeboxController.instance.send :resume }
	  redirect to('/')
  end
	get "/next" do 
		EM.defer do
			JukeboxController.instance.send :next
		end
		redirect to("/")
	end
	
	
end

