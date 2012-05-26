class User < ActiveRecord::Base
  has_one :user_detail
  has_many :user_service_details
  has_many :media, :class_name=> 'Media'
end
