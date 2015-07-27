require "sinatra/activerecord/rake"
require_relative './app'

require 'bundler/setup'
 
require 'active_record'
 
include ActiveRecord::Tasks
 
db_dir = File.expand_path('../db', __FILE__)
config_dir = File.expand_path('../config', __FILE__)
 
DatabaseTasks.env = ENV['DEPLOY_ENVIRONMENT'] || 'development'
DatabaseTasks.db_dir = db_dir
DatabaseTasks.database_configuration = YAML.load(File.read(File.join(config_dir, 'database.yml')))
DatabaseTasks.migrations_paths = File.join(db_dir, 'migrate')
 
task :environment do
  #ActiveRecord::Base.table_name_prefix = 'error_'
  ActiveRecord::Base.configurations = DatabaseTasks.database_configuration
  ActiveRecord::Base.establish_connection DatabaseTasks.env
end
 
load 'active_record/railties/databases.rake'