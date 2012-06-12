module GlobalConstant
  # Facebook connect variables
  FACEBOOK_CONFIG = YAML::load(File.open(Rails.root.to_s+'/config/facebook.yml'))[Rails.env]


  # Twitter connect variables
  TWITTER_CONFIG = YAML::load(File.open(Rails.root.to_s+'/config/twitter.yml'))[Rails.env]
end