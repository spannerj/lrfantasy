class Scores < ActiveRecord::Migration
  def up
	create_table :scores do |t|
		t.string :code
		t.string :scores
		# t.string :week
		# t.string :opposition
		# t.integer :goals
		# t.integer :key_contribution
		# t.integer :started_game
		# t.integer :substitute_appearance
		# t.integer :yellow_card
		# t.integer :red_card
		# t.integer :missed_penalties
		# t.integer :saved_penalties
		# t.integer :own_goal
		# t.integer :conceded
		# t.integer :clean_sheet_full
		# t.integer :clean_sheet_part
		# t.integer :points

		t.index :code, unique: true
	end
  end

  #drop	
  def down
  	drop_table :scores
  end
end
