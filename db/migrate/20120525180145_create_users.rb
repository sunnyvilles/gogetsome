class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.column :email, :string
      t.column :password, :string
      t.column :auth, :string
      t.column :fb_user_id, 
      t.column :twitter_id, 
      t.string :invite_code, :null => false
      t.integer :requested_invites, :default => 0, :null => false
      t.integer :subscribed_users, :default => 0, :null => false
      t.timestamps
    end
    add_index :users, :email, :unique=>true, :name => "UNIQUE_EMAIL"
    add_index :users, :auth, :unique=>true, :name => "UNIQUE_AUTH"
    add_index :users, :fb_user_id, :unique=>true, :name => "UNIQUE_FB_USER_ID"
    add_index :users, :twitter_id, :unique=>true, :name => "UNIQUE_TWITTER_ID"
    add_index :users, :invite_code, :unique => true, :name => "UNIQUE_INVITE_CODE"
  end
end
