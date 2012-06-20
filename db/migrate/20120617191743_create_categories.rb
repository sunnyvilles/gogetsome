class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.string :name, :limit => 50 , :null => false
      t.timestamps
    end

    add_index :categories, :name, :unique => false
  end
end
