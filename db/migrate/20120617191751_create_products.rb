class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :name, :limit => 200 , :null => false
      t.string :url, :limit => 200 , :null => false
      t.string :primary_image_url, :limit => 200 , :null => false
      t.string :brand, :limit => 200 , :null => false
      t.integer :discount_price
      t.integer :actual_price
      t.integer :category_id
      t.integer :sub_category_id
      t.column :status, "tinyint(1)", :null => false, :default => 0
      t.integer :views
      t.integer :country_id
      t.integer :site_id
      t.timestamps
    end

    add_index :products, :url, :name => "UNIQUE_URL", :unique => true
  end
end
