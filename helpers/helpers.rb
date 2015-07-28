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
			code = links_array[index][-4,4]
			name = b.p(:id => 'stats-name').text
			team = b.p(:id => 'stats-team').text
			value = b.p(:id => 'stats-value').text
			position = b.p(:id => 'stats-position').text

			sql = %{
								INSERT into players
								(code, name, team, value, position)
								VALUES ('#{code}', '#{name}', '#{team}', '#{value}', '#{position}')
						 }
			ActiveRecord::Base.connection.execute(sql)

			#extract points info
			b.table(:class, "data sortable").tbody.rows.each do |row|
				row.cells.each_with_index do |cell, index|
					case index
						when 0 
							week = cell.text
						when 1 
							team = cell.text
						when 2 
							goals = cell.text
						when 3 
							kc = cell.text
						when 4 
							started = cell.text
						when 5 
							sub = cell.text
						when 6 
							yellow = cell.text
						when 7 
							red = cell.text
						when 8 
							pen_miss = cell.text
						when 9 
							og = cell.text
						when 10 
							pts = cell.text
					end
				end

			  	sql = %{
							INSERT into scores
							(code,week,opposition,goals,key_contribution,started_game,substitute_appearance,
						     yellow_card,red_card,missed_penalties,saved_penalties,own_goal,conceeded,
						     clean_sheet_full,clean_sheet_part,points)
							VALUES
							('#{code}','#{week}','#{opposition}','#{goals}','#{key_contribution}','#{started_game}','#{substitute_appearance}',
						     '#{yellow_card}','#{red_card}','#{missed_penalties}','#{saved_penalties}','#{own_goal}','#{conceeded}',
						     '#{clean_sheet_full}','#{clean_sheet_part}','#{points}')
						}
				ActiveRecord::Base.connection.execute(sql)
			end
		end
		b.close
  	end
  end	
end