require 'active_record'
require 'rubygems'
require 'sinatra'
require 'capybara'
require './environments'

require_relative 'helpers/helpers'

# require 'phantomjs'
# Capybara.register_driver :poltergeist do |app|
#     Capybara::Poltergeist::Driver.new(app, :phantomjs => Phantomjs.path)
# end

#use Rack::Logger

class Footy < Sinatra::Base

	set :bind, '0.0.0.0'

	#register helpers for use
	helpers Sinatra::Helpers

	#ActiveRecord::Base.logger = Logger.new(File.open('database.log', 'w'))
	ActiveRecord::Base.logger = Logger.new(STDOUT)

	ActiveRecord::Base.establish_connection(
	  :adapter  => 'sqlite3',
	  :database => 'db/development.sqlite3'
	)

	class Player < ActiveRecord::Base
	end

	get '/' do
	 erb :index
	end

	#Players
	get '/players' do	
	  @players = Player.order(:code, value: :desc)
	  erb :'players/all'
	end

	post '/populatePlayers' do
	    insert_player
	    redirect '/players'
	end

	# get '/player/new' do
	#   @player = Player.new
	#   haml :'players/new'
	# end

	# post '/players' do
	#   @player = Player.new(params[:player])
	#   if @player.save
	#     redirect "/players/#{@player.id}"
	#   else
	#     "There was a problem saving that..."
	#   end
	# end

	# get '/players/:id' do
	#   @player = Player.find(params[:id])
	#   haml :'players/show'
	# end

end	