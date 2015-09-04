class AppStatus < ActiveRecord::Migration
  def up
    create_table :app_status do |t|
		t.timestamp :last_refresh
		t.boolean :scraping
	end
  end

  def down
    drop_table :app_status
  end
end
