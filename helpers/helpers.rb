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

		def get_display_data
			players = []
			sql = '
							select players.code, name, team, value, position, total, scores
							from players, scores
							where scores.code = players.code
							order by substr(players.code,1,1), value desc
						'
			res = ActiveRecord::Base.connection.exec_query(sql)

			res.each do | player |
				player = format_player_scores(player)
				players.push(player)
			end

			#calculate weeks
			weeks = calculate_weeks
			last6weeks = weeks[0..5]

			return weeks, last6weeks, players
		end

		def format_player_scores(player)
			week_scores = []
			weeks = player['scores'].split('@')

			weeks.each do | week |

				values = week.split(',')

				case player['position']
					when 'Goalkeeper'
						points = values[14].to_i
					when 'Defender'
						points = values[13].to_i
					when 'Midfielder', 'Striker'
						points = values[10].to_i
				end

				existing_week_index = check_existing_week(week_scores, values[0])
				if existing_week_index >= 0
					week_scores[existing_week_index]['total'] = week_scores[existing_week_index]['total'] + points
				else
					score = {}
					score['week'] = values[0]
					score['total'] =  points
					week_scores.push(score)
				end

			end

			player['scores'] = week_scores

			player
		end

		def check_existing_week(week_scores, new_week)
			week_scores.each_with_index do | week, i |
				if week['week'] == new_week
					return i
				end
			end

			-1
		end

		def calculate_weeks
			scores = Score.pluck(:scores)
			week_set = Set.new

			scores.each do | score |
				weeks = score.split('@')
				weeks.each do |week|
					values = week.split(',')
					week_set.add values[0].to_i
				end
			end
			weeks = week_set.to_a
			weeks.sort!
			weeks.reverse!
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

				unless Player.exists?(:code => player.code)
					player.save
				else
					db_player = Player.find_by(:code => player.code)
					db_player.update(:total => player.total)
				end

				scores = ''
				player_page.search('#individual-player tbody tr').each do |row|
					week_score = ''

					row.search('td').each do |cell|
						week_score = week_score + cell.text + ','
					end

					scores = scores + week_score.chomp(',') + '@'
				end

				begin
					Score.where( :code => player.code ).first_or_create( :code => player.code ).update( :scores => scores.chomp('@') )
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
