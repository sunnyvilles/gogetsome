class CreateRequestedInvites < ActiveRecord::Migration
  def change
    create_table :requested_invites do |t|
      t.string :email, :limit => 80, :null => false
      t.string :ip_address, :null => false
      t.string :city, :limit => 150
      t.string :state, :limit => 150
      t.string :country, :limit => 50
      t.string :zipcode, :limit => 30
      t.datetime :signedup_at
      t.integer :total_reminders_sent, :default => 0, :null => false
      t.string :subscription_code, :null => false
      t.string :invite_code, :null => false
      t.integer :requested_invites, :default => 0, :null => false
      t.integer :subscribed_users, :default => 0, :null => false
      t.timestamps
    end

    add_index :requested_invites, :email, :unique => true, :name => "UNIQUE_EMAILri"
    add_index :requested_invites, :subscription_code, :unique => true, :name => "UNIQUE_SUBSCRIPTION_CODE"
    add_index :requested_invites, :invite_code, :unique => true, :name => "UNIQUE_INVITE_CODEri"
  end
end
