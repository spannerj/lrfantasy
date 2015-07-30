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

	get '/' do
		@total = session['total']
		@started = session['started']
		#@players = Player.order('substr(code,1,1)', value: :desc)
		@weeks = Score.maximum(:week)
		@players = Player.find_by_sql('SELECT a.*, b.week, b.p
																	FROM players as a left outer join (select code, sum(points) as p, week from scores group by code, week) as b on a.code = b.code
																	group by a.id, b.p, b.week
																	order by substr(a.code,1,1), value desc, week  asc')
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
		flash[:notice] = 'Scraping has started, you will see a progress bar soon. Get a coffee as it takes about 25 minutes!'
	  redirect '/'
	end

end	