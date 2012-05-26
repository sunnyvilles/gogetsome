class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.column :primary_email, :string
      t.column :fb_user_id, "int(11)"
      t.column :instagram_id, "int(11)"
      t.column :twitter_id, "int(11)"
      t.column :flickr_id, "int(11)"
      t.column :picasa_id, "int(11)"
      t.timestamps
    end
    add_index :users, :fb_user_id, :unique=>true, :name => "UNIQUE_FB_USER_ID"
    add_index :users, :twitter_id, :unique=>true, :name => "UNIQUE_TWITTER_ID"
    add_index :users, :flickr_id, :unique=>true, :name => "UNIQUE_FLICKR_ID"
    add_index :users, :instagram_id, :unique=>true, :name => "UNIQUE_INSTAGRAM_ID"
    add_index :users, :picasa_id, :unique=>true, :name => "UNIQUE_PICASA_ID"
  end
end
