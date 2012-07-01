class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :name, :limit => 200
      t.string :url, :limit => 200 , :null => false
      t.string :primary_image_url, :limit => 200
      t.string :image_url_1, :limit => 200
      t.string :image_url_2, :limit => 200
      t.string :image_url_3, :limit => 200
      t.string :brand, :limit => 200
      t.integer :primary_image_width
      t.integer :primary_image_height
      t.integer :discount_price
      t.integer :actual_price
      t.integer :discount_percentage, :null => false, :default => 0
      t.integer :priority, :null => false, :default => 1
      t.column :status, "tinyint(1)", :null => false, :default => 0
      t.integer :views
      t.integer :country_id
      t.integer :site_id
      t.timestamps
    end

    add_index :products, :url, :name => "UNIQUE_URL", :unique => true
  end
end
