class Category < ActiveRecord::Base
  # attr_accessible :title, :body

  def self.get_categories_for_sort
    memcache_key = GlobalConstant::MEMCACHE_PREFIX+"sort_filter_categories"
    # Try to get data from memcache
    categories = Common.get_memcached(memcache_key, true)
    if categories.nil?
      associated_categories = {}
      filter_categories = Category.where(:name => GlobalConstant::MAIN_CATEGORY_LIST).select("name AS category, id").all
      filter_categories.each do |category|
        associated_categories[category.id] = []
        single_associated_categories = AssociatedCategory.where("parent_category_id = :category_id OR child_category_id = :category_id", :category_id => category.id).order("associated_products_count DESC").limit(GlobalConstant::SUB_CATEGORIES_PER_CATEGORY).all
        single_associated_categories.each do |cat|
          single_associated_categories << cat.parent_category_id if cat.parent_category_id != category.id
          single_associated_categories << cat.child_category_id if cat.child_category_id != category.id
        end
        Category.where(:id => single_associated_categories).each do |category|
          associated_categories[category.id] << {:id => category.id, :sub_category => category.name}
        end
      end
      categories = {:filter_categories => filter_categories, :associated_categories => associated_categories}
      
      Common.set_memcached(memcache_key, categories, 60.minutes.to_i, true)
    end
    return categories
  end
end
