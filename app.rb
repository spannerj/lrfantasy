require 'active_record'
require 'sinatra'
require 'sinatra/activerecord'
require './config/environments'
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
	
	# get '/test' do
	# 	@players = Player.find_by_sql("	SELECT code, array_agg(ROW(week, total)) AS week_array
	# 									FROM (select code, week, sum(points) as total
	# 									  from scores
	# 									  where code = '4001'
	# 									  group by code, week
	# 									  ORDER BY week) AS row
	# 									GROUP BY code
	# 									ORDER BY code ")

	# 	p @players.week_array								
	# 	puts @players.week_array[0]	
	# 	erb :'players/all'
	# end	

	get '/' do
		@total = session['total']
		@started = session['started']
		@players = Player.order('substr(code,1,1)', value: :desc)
		@weeks = Score.maximum(:week)
		@scores = Score.group(:week).order(:week).select(code, week,sum(points)) 
		p @weeks
		p @scores
		erb :'players/all'
	end

	get '/populatePlayers' do
		Thread.new do
			Player.delete_all
		end

		@started = true
		session['started'] = @started
		@total = get_player_count
		session['total'] = @total

		Thread.new do
			insert_player
		end
		flash[:notice] = 'Scraping has started. Get a coffee as it takes about 25 minutes!'
	  redirect '/'
	end

end	