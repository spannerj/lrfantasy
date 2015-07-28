require 'watir-webdriver'

# Sinatra module
module Sinatra
  # Helpers for Sinatra
  module Helpers

	def logger
		request.logger
	end

  	def insert_player
  		#b = Watir::Browser.new
  		b = Watir::Browser.new :phantomjs
  		b.goto 'https://fantasyfootball.telegraph.co.uk/premierleague/PLAYERS/all'
  		table_array = b.table(:class => "data sortable").links.to_a
  		links_array = []
  		table_array.each_with_index do |l, index|
		    if (index %2 == 0) then
		    	links_array.push(l.href)
		    end
		end

		links_array.each_with_index do |link, index|

			b.goto links_array[index]

			#store player id
			player = Player.new
			player.code = links_array[index][-4,4]
			player.name = b.p(:id => 'stats-name').text
			player.team = b.p(:id => 'stats-team').text
			player.value = b.p(:id => 'stats-value').text
			player.position = b.p(:id => 'stats-position').text
			player.save
			# sql = %{
			# 					INSERT into players
			# 					(code, name, team, value, position)
			# 					VALUES ('#{code}', '#{name}', '#{team}', '#{value}', '#{position}')
			# 			 }
			# ActiveRecord::Base.connection.execute(sql)

			score = Score.new
			score.code = code
			#extract points info
			b.table(:class, "data sortable").tbody.rows.each do |row|
				row.cells.each_with_index do |cell, index|
					case index
						when 0 
							score.week = cell.text
						when 1
							score.opposition = cell.text
						when 2
							score.goals = cell.text
						when 3
							score.key_contribution = cell.text
						when 4
							score.started_game = cell.text
						when 5
							score.substitute_appearance = cell.text
						when 6
							score.yellow_card = cell.text
						when 7
							score.red_card = cell.text
						when 8
							score.missed_penalties = cell.text
						when 9
							score.own_goal = cell.text
						when 10
							score.points = cell.text
					end
				end
				score.save

			  	# sql = %{
				# 			INSERT into scores
				# 			(code,week,opposition,goals,key_contribution,started_game,substitute_appearance,
				# 		     yellow_card,red_card,missed_penalties,saved_penalties,own_goal,conceeded,
				# 		     clean_sheet_full,clean_sheet_part,points)
				# 			VALUES
				# 			('#{code}','#{week}','#{opposition}','#{goals}','#{key_contribution}','#{started_game}','#{substitute_appearance}',
				# 		     '#{yellow_card}','#{red_card}','#{missed_penalties}','#{saved_penalties}','#{own_goal}','#{conceeded}',
				# 		     '#{clean_sheet_full}','#{clean_sheet_part}','#{points}')
				# 		}
				# ActiveRecord::Base.connection.execute(sql)
			end
		end
		b.close
  	end
  end	
end