class CreateAssociatedCategories < ActiveRecord::Migration
  def change
    create_table :associated_categories do |t|

      t.timestamps
    end
  end
end
