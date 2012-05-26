class Media < ActiveRecord::Base
  belongs_to :user, :class_name=> 'Media'
end
