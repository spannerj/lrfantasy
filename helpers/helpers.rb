require 'sinatra/base'
require 'nokogiri'
require 'open-uri'
require 'openssl'
require 'mongo_mapper'
require_relative '../config/db'
require_relative '../models/player'

OpenSSL::SSL.send(:remove_const, :VERIFY_PEER)
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

# Sinatra module
module Sinatra

  # Helpers for Sinatra
	module Helpers

		def get_player_codes
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
      link_list
    end

    def populate_database

      p 'Started'
      p Time.now

			@link_list.each_with_index do |link_code, i|
        player_url = 'https://fantasyfootball.telegraph.co.uk/premierleague/statistics/points/' + link_code
        player_page = Nokogiri::HTML(open(player_url))

        player = Player.first(:code => link_code)

        if player.nil?
          player = Player.create(:code => link_code)
          player.name = player_page.search('#stats-name').text
          player.team = player_page.search('#stats-team').text
          val = player_page.search('#stats-value').text
          player.value = val.match(/^[£](\d.\d)[m]$/)[1]
          player.position = player_page.search('#stats-position').text
          player.total = player_page.search('#stats-points').text
        end

        p 'Processing player '+ (i+1).to_s + ' of ' + @link_list.count.to_s + ', '+ 'code ' + player.code + ' who is ' + player.name + '.'

        scores = get_scores(player_page, player)

        diff =  scores - player.stats

        diff.each do |week|
          begin
            player.stats << week
          rescue e => error
            p error.message
          end
        end

        player.save
      end

      p 'Ended'
      p Time.now
    end

    def get_scores(player_page, player)
      begin
        player_page
        scores = []
        player_page.search('#individual-player tbody tr').each do |row|
          score = {}

          row.search('td').each_with_index do |cell, i|
            case i
              when 0
                score['week'] = cell.text
              when 1
                score['opposition'] = cell.text
              when 2
                score['goals'] = cell.text.to_i
              when 3
                score['key_contribution'] = cell.text.to_i
              when 4
                score['started_game'] = cell.text.to_i
              when 5
                score['substitute_appearance'] = cell.text.to_i
              when 6
                score['yellow_card'] = cell.text.to_i
              when 7
                score['red_card'] = cell.text.to_i
              when 8
                score['missed_penalties'] = cell.text.to_i
              when 9
                if player.position == 'Goalkeeper'
                  score['saved_penalties'] = cell.text.to_i
                else
                  score['own_goal'] = cell.text.to_i
                end
              when 10
                if player.position == 'Goalkeeper'
                  score['own_goal'] = cell.text.to_i
                elsif player.position == 'Defender'
                  score['conceded'] = cell.text.to_i
                else
                  score['points'] = cell.text.to_i
                end
              when 11
                if player.position == 'Goalkeeper'
                  score['conceded'] = cell.text.to_i
                else
                  score['clean_sheet_full'] = cell.text.to_i
                end
              when 12
                if player.position == 'Goalkeeper'
                  score['clean_sheet_full'] = cell.text.to_i
                else
                  score['clean_sheet_part'] = cell.text.to_i
                end
              when 13
                if player.position == 'Goalkeeper'
                  score['clean_sheet_part'] = cell.text.to_i
                else
                  score['points'] = cell.text.to_i
                end
              when 14
                score['points'] = cell.text.to_i
            end

          end
          scores << score
        end

        scores

      rescue e => error
        p error
      end
    end

  end

  helpers Helpers
end