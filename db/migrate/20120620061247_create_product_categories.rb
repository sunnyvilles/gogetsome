class CreateProductCategories < ActiveRecord::Migration
  def change
    create_table :product_categories do |t|
      t.integer :product_id, :null => false
      t.integer :category_id, :null => false
      t.timestamps
    end

    add_index :product_categories, :product_id, :unique => false
    add_index :product_categories, :category_id, :unique => false
  end
end
