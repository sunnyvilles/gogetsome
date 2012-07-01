class Product < ActiveRecord::Base
  # attr_accessible :title, :body

  scope :live_products, where(:status => 1)

  def self.get_products(params)
    params[:page] ||= 1
    page_level = ((params[:page]-1)/GlobalConstant::INDEX_PRODUCTS_PAGES_PER_LEVEL)+1
    if params[:category_id].to_i > 0
      # Create memcache key
      memcache_key = GlobalConstant::MEMCACHE_PREFIX+"index_products_level_#{page_level}"
      # Try to get data from memcache
      product_ids = Common.get_memcached(memcache_key, true)
      if product_ids.nil?
        product_ids = Product.where(:status => 1).order("priority").limit(GlobalConstant::PRODUCTS_PER_LEVEL_FOR_MEMCACHE).offset(GlobalConstant::PRODUCTS_PER_LEVEL_FOR_MEMCACHE*(page_level-1)).collect(&:id)
        puts "-----product_ids----#{product_ids.inspect}"
        Common.set_memcached(memcache_key, product_ids, 60.minutes.to_i, true)
      end
    else
      if params[:start_range].present? && params[:end_range].present?
        # Create memcache key
        memcache_key = GlobalConstant::MEMCACHE_PREFIX+"price_range_#{params[:start_range]}_#{params[:end_range]}_products_level_#{page_level}"
        # Try to get data from memcache
        product_ids = Common.get_memcached(memcache_key, true)
        if product_ids.nil?
          product_ids = Product.live_products.where("discount_price between ? AND ?", params[:start_range].to_f,params[:end_range].to_f).order("priority").limit(GlobalConstant::PRODUCTS_PER_LEVEL_FOR_MEMCACHE).offset(GlobalConstant::PRODUCTS_PER_LEVEL_FOR_MEMCACHE*(page_level-1)).pluck(:id)
          puts "-----product_ids----#{product_ids.inspect}"
          Common.set_memcached(memcache_key, product_ids, 60.minutes.to_i, true)
        end
      elsif ["ASC", "DESC"].include? params[:price_order].upper_case

      elsif ["ASC", "DESC"].include? params[:discount_order].upper_case
        
      else
        # Create memcache key
        memcache_key = GlobalConstant::MEMCACHE_PREFIX+"index_products_level_#{page_level}"
        # Try to get data from memcache
        product_ids = Common.get_memcached(memcache_key, true)
        if product_ids.nil?
          product_ids = Product.live_products.where(:status => 1).order("priority").limit(GlobalConstant::PRODUCTS_PER_LEVEL_FOR_MEMCACHE).offset(GlobalConstant::PRODUCTS_PER_LEVEL_FOR_MEMCACHE*(page_level-1)).collect(&:id)
          puts "-----product_ids----#{product_ids.inspect}"
          Common.set_memcached(memcache_key, product_ids.shuffle, 60.minutes.to_i, true)
        end
      end
      
    end
    current_page_product_ids = product_ids[(((params[:page]%GlobalConstant::INDEX_PRODUCTS_PAGES_PER_LEVEL)-1)*GlobalConstant::PRODUCTS_PER_EACH_PAGE)..(((params[:page]%GlobalConstant::INDEX_PRODUCTS_PAGES_PER_LEVEL))*GlobalConstant::PRODUCTS_PER_EACH_PAGE)-1]
    logger.debug("---current_page_product_ids----#{current_page_product_ids.inspect}")
    current_page_products = Product.where(:id => current_page_product_ids).all
    return {:products => current_page_product_ids}
  end
	
end
