class CreateAssociatedCategories < ActiveRecord::Migration
  def change
    create_table :associated_categories do |t|
      t.integer :parent_category_id, :null => false
      t.integer :child_category_id, :null => false
			t.integer :associated_products_count, :null => false, default=>0
      t.timestamps
    end

    add_index :associated_categories, [:parent_category_id, :child_category_id], :unique => true, :name => "UNIQUE_CAT_ASSOC"
    add_index :associated_categories, :parent_category_id, :unique => false
    add_index :associated_categories, :child_category_id, :unique => false
  end
end
