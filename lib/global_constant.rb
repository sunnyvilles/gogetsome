module GlobalConstant
  # Facebook connect variables
  FACEBOOK_CONFIG = YAML::load(File.open(Rails.root.to_s+'/config/facebook.yml'))[Rails.env]


  # Twitter connect variables
  TWITTER_CONFIG = YAML::load(File.open(Rails.root.to_s+'/config/twitter.yml'))[Rails.env]

  # Number of products per level EX:: First 50 products of each category are level and next 50 products are in level 2 category etc.,
  PRODUCTS_PER_EACH_LEVEL = 3

  # Number of products per page
  PRODUCTS_PER_EACH_PAGE = 40

  # Root url
  MEMCACHE_PREFIX = Picshub::Application.config.memcache_prefix.freeze
  # set the memcached object
  MemcachedObject = Picshub::Application.config.memcached_object.freeze if !["test"].include?(Rails.env)

  # Pages per level for Index page
  INDEX_PRODUCTS_PAGES_PER_LEVEL = 4

  # Products per each level
  PRODUCTS_PER_LEVEL_FOR_MEMCACHE = PRODUCTS_PER_EACH_PAGE*INDEX_PRODUCTS_PAGES_PER_LEVEL
  
end