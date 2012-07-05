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
  # * <b>params[:priority]</b> <em>(Integer)</em> - Priority of the Product
  # * <b>params[:discount_price]</b> <em>(Integer)</em> - Product Price
  # * <b>params[:discount_percentage]</b> <em>(Integer)</em> - Product DIscount
  #
  def self.create_update_product_categories(params)
    params[:categories].map!{|c| c.strip.downcase}
    logger.debug("----params[:categories]-----#{params[:categories].inspect}")
    indexed_categories = Category.where(:name => params[:categories]).index_by(&:name)
    existing_category_ids, all_category_ids = [], []
    params[:categories].each do |cat_key_word|
      begin
        category = indexed_categories[cat_key_word]
        if category.nil?
          category = Category.create(:name => cat_key_word.downcase, :associated_products_count => 1)
          all_category_ids << category.id
        else
          existing_category_ids << category.id
          all_category_ids << category.id
        end
        begin
          ProductCategory.create(:product_id => params[:product_id], :category_id => category.id,
                                 :priority => params[:priority], :discount_price => params[:discount_price],
                                 :discount_percentage => params[:discount_percentage]
                                )
        rescue
          existing_category_ids.delete(category.id)
          all_category_ids.delete(category.id)
        end
        
      end

    end

    AssociatedCategory.add_update_associated_categories(all_category_ids) if all_category_ids.length > 1

    Category.update_all("associated_products_count = associated_products_count + 1", ["id IN (?)", existing_category_ids]) if existing_category_ids.present?
  end
end
