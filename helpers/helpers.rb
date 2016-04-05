require 'nokogiri'
require 'open-uri'
require 'openssl'

OpenSSL::SSL.send(:remove_const, :VERIFY_PEER)
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

# Sinatra module
module Sinatra
  # Helpers for Sinatra
	module Helpers

		class Player < ActiveRecord::Base
		end
	
		class Score < ActiveRecord::Base
		end
		
		class AppStatu < ActiveRecord::Base
		end

		def get_player_codes
			as = AppStatu.first
			url = 'https://fantasyfootball.telegraph.co.uk/premierleague/players/all'
			data = Nokogiri::HTML(open(url))
			link_list = []
			data.search('.clubdata tbody tr').each do |row|
				row.search('td').each do |td|
					links = td.css('a')
					unless links[0].nil?
						link_list.push(links[0]['href'][-4,4])
					end
				end
			end
			as.player_count = link_list.count
			as.save
			link_list
		end

  	def populate_database
	  	# Player.delete_all
			# Score.delete_all

			p 'Started'
			p Time.now
			as = AppStatu.first
			as.started = Time.now.iso8601
			as.scraping = true
			as.save

			@link_list.each_with_index do |link_code, i|
				player_url = 'https://fantasyfootball.telegraph.co.uk/premierleague/statistics/points/' + link_code
				player_page = Nokogiri::HTML(open(player_url))
				player = Player.new
				player.code = link_code
				player.name = player_page.search('#stats-name').text
				as.current_player = i+1
				as.save

				p 'Processing player '+ (i+1).to_s + ' of ' + @link_list.count.to_s + ', '+ 'code ' + player.code + ' who is ' + player.name + '.'

				player.team = player_page.search('#stats-team').text
				val = player_page.search('#stats-value').text
				player.value = val.match(/^[£](\d.\d)[m]$/)[1]
				player.position = player_page.search('#stats-position').text
				player.total = player_page.search('#stats-points').text

				if !Player.exists?(:code => player.code)
					player.save
				else
					db_player = Player.find_by(:code => player.code)
					db_player.update(:total => player.total)
				end

				score = Score.new
				score.code = player.code
				scores = ''
				player_page.search('#individual-player tbody tr').each do |row|
					week_score = '@'

					row.search('td').each do |cell|
						week_score = week_score + cell.text + ','
					end

					p week_score
					scores = scores + week_score.chomp
				end
				score.opposition = scores
				p score

				begin
					score.save
				rescue Exception => e
					p e.message
				end
			end

			@started = false
			p 'Ended'
			p Time.now

			as.finished = Time.now.iso8601
			as.scraping = false
			as.current_player = 0
			as.save
		end

		def app_init
			if AppStatu.take.nil?
				as = AppStatu.new(scraping: false, player_count: 0, current_player: 0, finished: Time.now.iso8601)
				as.save
			end
		end

	end

end
