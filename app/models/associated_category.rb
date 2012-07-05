class AssociatedCategory < ActiveRecord::Base
  
  # attr_accessible :title, :body
  def self.add_update_associated_categories(categories)
    categories.each do |category1|
      categories.delete(category1)
      categories.each do |category2|
        if AssociatedCategory.update_all("associated_products_count = associated_products_count + 1", ["(parent_category_id = :category1 AND child_category_id = :category2) OR (parent_category_id = :category2 AND child_category_id = :category1)", :category1 => category1, :category2 => category2]) == 0
          AssociatedCategory.create(:parent_category_id => category1, :child_category_id => category2, :associated_products_count => 1)
        end
      end
    end
  end
end
