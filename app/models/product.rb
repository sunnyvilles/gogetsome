class Product < ActiveRecord::Base
  # attr_accessible :title, :body

  scope :live_products, where("status = 1 AND priority > 0")

  def self.get_products(params)
    params[:page] ||= 1
    page_level = ((params[:page]-1)/GlobalConstant::INDEX_PRODUCTS_PAGES_PER_LEVEL)+1
    append_key, append_order_condition = sort_request_key(params)
    memcache_key = GlobalConstant::MEMCACHE_PREFIX+"#{params[:category_id].to_i > 0 ? "category_"+params[:category_id].to_s : "all"}_#{params[:start_range].to_i}_#{params[:end_range].to_i}#{append_key}_level_#{page_level}"
    # Try to get data from memcache
    product_ids = Common.get_memcached(memcache_key, true)
    if product_ids.nil?
      if params[:category_id].to_i > 0
        product_ids = ProductCategory.where(:category_id => params[:category_id])
      else
        product_ids = Product.live_products
      end
      if params[:price_filter].present?
        price_filter = GlobalConstant::PRICE_FILTER[params[:price_filter]]
        params[:start_range] = price_filter[:start_price]
        params[:end_range] = price_filter[:end_price]
      end
      if params[:start_range].present?
        product_ids = product_ids.where("discount_price >= ?", params[:start_range].to_f)
      elsif params[:end_range].present?
        product_ids = product_ids.where("discount_price <= ?", params[:end_range].to_f)
      end
      if params[:category_id].to_i > 0
        product_ids = product_ids.order(append_order_condition).limit(GlobalConstant::PRODUCTS_PER_LEVEL_FOR_MEMCACHE).offset(GlobalConstant::PRODUCTS_PER_LEVEL_FOR_MEMCACHE*(page_level-1)).pluck(:product_id)
      else
        product_ids = product_ids.order(append_order_condition).limit(GlobalConstant::PRODUCTS_PER_LEVEL_FOR_MEMCACHE).offset(GlobalConstant::PRODUCTS_PER_LEVEL_FOR_MEMCACHE*(page_level-1)).pluck(:id)
      end
      
      puts "-----product_ids----#{product_ids.inspect}"

      #Common.set_memcached(memcache_key, product_ids, 60.minutes.to_i, true)
    end
    
    current_page_product_ids = product_ids[(((params[:page]%GlobalConstant::INDEX_PRODUCTS_PAGES_PER_LEVEL)-1)*GlobalConstant::PRODUCTS_PER_EACH_PAGE)..(((params[:page]%GlobalConstant::INDEX_PRODUCTS_PAGES_PER_LEVEL))*GlobalConstant::PRODUCTS_PER_EACH_PAGE)-1]
    logger.debug("---current_page_product_ids----#{current_page_product_ids.inspect}")
    current_page_products = Product.where(:id => current_page_product_ids).all
    return {:products => current_page_products}
  end

  private

  def self.sort_request_key(params)
    if (["discount_price", "discount_percentage"].include?(params[:order_by]) && ["ASC", "DESC"].include?(params[:order_type]))
      append_key = "_#{params[:order_by]}_#{params[:order_type]}"
      append_order_condition = "#{params[:order_by]} #{params[:order_type]}, priority ASC"
    else
      append_key = ""
      append_order_condition = "priority ASC"
    end
    return append_key, append_order_condition
  end
	
end
