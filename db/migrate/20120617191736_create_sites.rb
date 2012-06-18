class CreateSites < ActiveRecord::Migration
  def change
    create_table :sites do |t|
      t.string :name, :limit => 50 , :null => false
      t.string :site_url, :limit => 50 , :null => false
      t.integer :country_id, :null => false, :default => 1
      t.timestamps
    end
  end
end
