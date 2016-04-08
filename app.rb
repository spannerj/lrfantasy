require 'active_record'
require 'sinatra'
require 'sinatra/reloader' if development?
require './config/environments'
require 'sinatra/activerecord'

require_relative 'helpers/helpers'

helpers do
	include Rack::Utils
end

class Footy < Sinatra::Base

	configure :development do
		register Sinatra::Reloader
	end

  # set :bind, '0.0.0.0'
  # set :port, 4567

	#register helpers for use
	helpers Sinatra::Helpers

	#ActiveRecord::Base.logger = Logger.new(STDOUT)

	#initialise app
	before do
		app_init
	end

	get '/sql' do
		content_type :json
		sql = 'select players.code, name, team, value, position, total, scores from players, scores where scores.code = players.code'
		res = ActiveRecord::Base.connection.exec_query(sql)
		player = res[0]
		player.to_json
	end

	get '/' do
		@weeks, @last6weeks, @players = get_display_data
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
