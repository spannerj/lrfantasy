class AppStatus < ActiveRecord::Migration
  def up
    create_table :app_status do |t|
      t.timestamp :started
      t.timestamp :finished
      t.boolean :scraping
      t.integer :player_count
      t.integer :current_player
	end
  end

  def down
    drop_table :app_status
  end
end
