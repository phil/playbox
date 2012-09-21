namespace :db do

  #desc "Creates the Database"
  #task :create do
  #end
  
  desc "reset"
  task :reset => :environment do
    require 'dm-migrations'
    DataMapper.auto_migrate!
  end
  
  desc "Seed DB with "
  task :seed => :environment do
    User.create :login => "rainbowhead"
  end
  
end
