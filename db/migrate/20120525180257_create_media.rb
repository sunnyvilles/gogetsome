class CreateMedia < ActiveRecord::Migration
  def change
    create_table :media do |t|
      t.integer :user_id, :null => false, :default => 0
      #t.column :service_id, "ENUM('1','2','3','4','5')"
      t.column :media_url, :string
      t.column :thumb_image_url, :string
      t.column :theme_id, :integer
      t.column :view_count, :integer, :null => false, :default => 0
      #t.column :media_type, "ENUM('1','2')"
      t.timestamps
    end
    execute "ALTER TABLE `media` ADD `service_id` ENUM('1', '2', '3', '4') NOT NULL DEFAULT '1' COMMENT '1 => Facebook, 2 => Instagram, 3 => Twitter, 4 => Flickr, 5 => Picasa' AFTER `user_id`  ;"
    execute "ALTER TABLE `media` ADD `media_type` ENUM('1', '2') NOT NULL DEFAULT '1' COMMENT '1 => Facebook, 2 => Instagram, 3 => Twitter, 4 => Flickr, 5 => Picasa' AFTER `user_id`  ;"
    add_index :media, :user_id, :name => "primary_index"
  end
end
