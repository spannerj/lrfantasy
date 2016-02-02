require 'active_record'
require 'sinatra'
require 'sinatra/reloader'
require './config/environments'
require 'sinatra/activerecord'
require 'sinatra/flash'
require 'sinatra/redirect_with_flash'

require_relative 'helpers/helpers'

helpers do
	include Rack::Utils
end

class Footy < Sinatra::Base
	set :bind, '0.0.0.0'
  set :port, 4567

	#register helpers for use
	helpers Sinatra::Helpers

	#ActiveRecord::Base.logger = Logger.new(STDOUT)

	register Sinatra::Flash

	get '/' do
		@players = Player.order('substr(code,1,1)', value: :desc).as_json
		@weeks = []
    unsorted_weeks = Score.select(:week).distinct.order(week: :desc)
    unsorted_weeks.each do |res|
      @weeks.push(res.week.to_i)
    end
    @weeks.sort!
    @weeks.reverse!
    @last6weeks = []
    @last6weeks = @weeks[0..5]
		@scores = Score.group(:week, :code).order(:week).select('code, week, sum(points) as total').as_json 
		
		@players.each do | player |
			week_scores = []
			@scores.each do | score |
				if (player['code'] == score['code'])
					week_scores.push(score)
				end	
			end
			player['scores'] = week_scores
    end

		erb :'players/all'
	end
	

	# get '/populatePlayers' do
	# 	Thread.new do
	# 		populate_database
   #  end
  #
	# 	flash[:notice] = 'Scraping has started. Get a coffee as it takes about 25 minutes!'
	#   redirect '/'
	# end
	
	get '/cron' do
    @link_list = get_player_codes
		Thread.new do
			populate_database
		end
		status 200
	end	
end