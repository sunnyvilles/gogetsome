class CreateUserDetails < ActiveRecord::Migration
  def change
    create_table :user_details do |t|
      t.column :user_id, :integer, :null => false
      t.column :remote_ip, "varchar(25)", :null => false
      t.column :city, "varchar(200)"
      t.column :region, "varchar(200)"
      t.column :country, "varchar(200)"
      t.column :zipcode, "varchar(20)"
      t.timestamps
    end
    add_index :user_details, :user_id, :unique=>true, :name => "UNIQUE"
  end
end
