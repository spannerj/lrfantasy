require 'watir-webdriver'

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
	
		def logger
			request.logger
		end
		
		def get_player_count
			b = Watir::Browser.new :phantomjs
			begin
				b.goto 'https://fantasyfootball.telegraph.co.uk/premierleague/PLAYERS/all'
				row_count = b.table(:class => "data sortable").tbody.rows.length
			ensure
				b.close
			end
			row_count
		end
	
	  	def populate_database
	  		Player.delete_all
			Score.delete_all
		
			b = Watir::Browser.new :phantomjs
			begin
				b.goto 'https://fantasyfootball.telegraph.co.uk/premierleague/PLAYERS/all'
				table_array = b.table(:class => "data sortable").links.to_a
				links_array = []
				table_array.each_with_index do |l, index|
					
				#if (index %2 == 0) then
					links_array.push(l.href)
				#end
			end
	
			links_array.each_with_index do |link, index|
	
				b.goto links_array[index]
				
				#store player id
				player = Player.new
				player.code = links_array[index][-4,4]
				puts player.code
				player.name = b.p(:id => 'stats-name').text
				player.team = b.p(:id => 'stats-team').text
				val = b.p(:id => 'stats-value').text
				player.value = val.match(/^[£](\d.\d)[m]$/)[1]
				player.position = b.p(:id => 'stats-position').text
				player.total = b.p(:id => 'stats-points').text
				
				if !Player.exists?(:code => player.code)
					player.save
				else
					db_player = Player.find_by(:code => player.code)
					db_player.update(:total => player.total)
				end	
	
				b.goto link
					
				#extract points info
				b.table(:class, "data sortable").tbody.rows.each do |row|
					score = Score.new
					score.code = player.code
					row.cells.each_with_index do |cell, i|
						case i
							when 0
								score.week = cell.text
							when 1
								score.opposition = cell.text
							when 2
								score.goals = cell.text.to_i
							when 3
								score.key_contribution = cell.text.to_i
							when 4
								score.started_game = cell.text.to_i
							when 5
								score.substitute_appearance = cell.text.to_i
							when 6
								score.yellow_card = cell.text.to_i
							when 7
								score.red_card = cell.text.to_i
							when 8
								score.missed_penalties = cell.text.to_i
							when 9
								if player.position == 'Goalkeeper'
									score.saved_penalties = cell.text.to_i	
								else	
									score.own_goal = cell.text.to_i
								end	
							when 10
								if player.position == 'Goalkeeper'
									score.own_goal = cell.text.to_i	
								elsif player.position == 'Defender'	
									score.conceded = cell.text.to_i
								else
									score.points = cell.text.to_i	
								end	
							when 11
								if player.position == 'Goalkeeper'
									score.conceded = cell.text.to_i	
								else
									score.clean_sheet_full = cell.text.to_i	
								end	
							when 12
								if player.position == 'Goalkeeper'
									score.clean_sheet_full = cell.text.to_i	
								else
									score.clean_sheet_part = cell.text.to_i	
								end	
							when 13
								if player.position == 'Goalkeeper'
									score.clean_sheet_part = cell.text.to_i	
								else
									score.points = cell.text.to_i	
								end	
							when 14
								score.points = cell.text.to_i
						end
					end
					if !Score.exists?(:code => score.code, :opposition => score.opposition, :week => score.week)
						score.save
					end	
				end
			end
			as = AppStatu.take
			as.last_refresh = Time.now.iso8601
			as.save
			ensure
				b.close
			end
		end
  	end	
end
