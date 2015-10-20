require 'active_record'
require 'sinatra'
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

	#register helpers for use
	helpers Sinatra::Helpers

	ActiveRecord::Base.logger = Logger.new(STDOUT)

	enable :sessions
	register Sinatra::Flash

	before do
		if session['total'].nil?
			session['total'] = 0
		end
		if session['started'].nil?
			session['started'] = false
		end
	end

	get '/' do
		@total = session['total']
		@started = session['started']
		
		@players = Player.order('substr(code,1,1)', value: :desc).as_json
		@weeks = Score.select(:week).distinct.order(week: :desc)
	    unsorted_weeks = Score.select(:week).distinct.order(week: :desc)
	    unsorted_weeks.each do |res| 
	    	@weeks.push(res.week)
	    end
	    @weeks.reverse!
	    @last6weeks = []
	    @last6weeks =@weeks[0..5]
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
	

	get '/populatePlayers' do
		# Thread.new do
		# 	Player.delete_all
		# 	Score.delete_all
		# end

		@started = true
		session['started'] = @started
		@total = get_player_count
		session['total'] = @total

		Thread.new do
			populate_database
		end
		flash[:notice] = 'Scraping has started. Get a coffee as it takes about 25 minutes!'
	  redirect '/'
	end
	
	get '/cron' do
		Thread.new do
			populate_database
		end
		halt 200
	end	
end	
