class CreateProductViews < ActiveRecord::Migration
  def change
    create_table :product_views do |t|
      t.integer :product_id, :null => false
      t.string :ip_address
      t.integer :site_id, :null => false
      t.timestamps
    end
  end
end
