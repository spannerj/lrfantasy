class Scores < ActiveRecord::Migration
  def up
	create_table :scores do |t|
		t.string :code
		t.string :week
		t.string :opposition
		t.string :goals
		t.string :key_contribution
		t.string :started_game
		t.string :substitute_appearance
		t.string :yellow_card
		t.string :red_card
		t.string :missed_penalties
		t.string :saved_penalties
		t.string :own_goal
		t.string :conceded
		t.string :clean_sheet_full
		t.string :clean_sheet_part
		t.string :points

		t.index :code, unique: false
	end
  end

  def down
  	drop_table :scores
  end
end
