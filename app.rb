require 'sinatra'
require 'sinatra/reloader' if development?
require './config/environments'
require_relative 'helpers/helpers'

MongoMapper.connection = Mongo::Connection.new('localhost', 27017)
MongoMapper.database = 'fantasy'
Player.ensure_index(:code)

class Footy < Sinatra::Base

  configure :development do
    register Sinatra::Reloader
    also_reload 'helpers/helpers'
  end

	set :bind, '0.0.0.0'
  set :port, 4567

  configure do
    register Sinatra::Reloader
    also_reload './helpers/helpers.rb'
    helpers Sinatra::Helpers
  end

  get '/players/populate' do
    @link_list = get_player_codes
    Thread.new do
      populate_database
    end
    status 200
  end

	get '/players/all' do
		@players = Player.order('substr(code,1,1)', value: :desc).as_json

    @weeks = []
    unsorted_weeks = MongoMapper.database.eval(' db.players.distinct("stats.week").sort( { week: -1 } ) ')
    unsorted_weeks.each do |res|
      @weeks.push(res.to_i)
    end
    @weeks.sort!
    @weeks.reverse!

    @last6weeks = []
    @last6weeks = @weeks[0..5]

		erb :'players/all'
	end
	
	get '/cron' do
    @link_list = get_player_codes
		Thread.new do
			populate_database
		end
		status 200
	end	
end