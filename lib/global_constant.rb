module GlobalConstant
  # Facebook connect variables
  FACEBOOK_CONFIG = YAML::load(File.open(Rails.root.to_s+'/config/facebook.yml'))[Rails.env]


  # Twitter connect variables
  TWITTER_CONFIG = YAML::load(File.open(Rails.root.to_s+'/config/twitter.yml'))[Rails.env]

  # Number of products per level EX:: First 50 products of each category are level and next 50 products are in level 2 category etc.,
  PRODUCTS_PER_EACH_LEVEL = 3

  # Number of products per page
  PRODUCTS_PER_EACH_PAGE = 20

  # Root url
  MEMCACHE_PREFIX = "d_"#Picshub::Application.config.memcache_prefix.freeze
  # set the memcached object
  

  # Pages per level for Index page
  INDEX_PRODUCTS_PAGES_PER_LEVEL = 4

  # Products per each level
  PRODUCTS_PER_LEVEL_FOR_MEMCACHE = PRODUCTS_PER_EACH_PAGE*INDEX_PRODUCTS_PAGES_PER_LEVEL

  # Main category list
  MAIN_CATEGORY_LIST = ["Men", "Women", "Kids", "Sports", "Home & Living"]

  PRICE_FILTER = {1 => {:start_price => 0, :end_price => 499},
                  2 => {:start_price => 500, :end_price => 999},
                  3 => {:start_price => 1000, :end_price => 1999},
                  4 => {:start_price => 2000}
                 }

  SUB_CATEGORIES_PER_CATEGORY = 10
  
end