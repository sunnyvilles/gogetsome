class ProductCategory < ActiveRecord::Base
  belongs_to :product
  belongs_to :category

  # Method to create/update product_category records
  #
  # Date:: 24/06/2012
  #
  # <b>Expects</b>
  # * <b>params[:categories]</b> <em>(Array)</em> - Array of categories
  # * <b>params[:product_id]</b> <em>(Integer)</em> - Product ID
  #
  def self.create_update_product_categories(params)
    indexed_categories = Category.where(:name => params[:categories]).index_by(&:name)
    existing_category_ids = []
    params[:categories].each do |cat_key_word|
      category = indexed_categories[cat_key_word]
      if category.nil?
        category = Category.create(:name => cat_key_word.downcase, :associated_products_count => 1)
      else
        existing_category_ids << category.id
      end

      ProductCategory.create(:product_id => params[:product_id], :category_id => category.id)
    end

    Category.update_all("associated_products_count = associated_products_count + 1", ["id IN (?)", existing_category_ids]) if existing_category_ids.present?
  end
end
