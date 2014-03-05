require 'bundler'
ENV['BUNDLE_GEMFILE'] = File.expand_path("Gemfile")
Bundler.setup
Bundler.require(:default) if defined?(Bundler)

ROOT = File.expand_path("#{__FILE__}/../../")
MEDIA_FOLDER = File.join(ROOT, "media")
#puts ROOT

# include all libs
#puts libs = File.join("**", "lib", "*", "*.rb")
Dir.glob("**/lib/*/*.rb") do |rb|
	require File.expand_path(rb)
end


# DataMapper.setup(:default, 'sqlite:///path/to/project.db')
DataMapper.setup(:default, 'mysql://localhost/jukebox_development')
DataMapper.finalize
