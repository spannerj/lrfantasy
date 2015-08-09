class CreatePlayers < ActiveRecord::Migration
  def up
  	  create_table :players do |t|
      	t.string :code
      	t.string :name
      	t.string :team
      	t.string :value
        t.string :position
        t.string :total

        t.index :code, unique: true
  	  end
  end

  def down
  	drop_table :players
  end
end