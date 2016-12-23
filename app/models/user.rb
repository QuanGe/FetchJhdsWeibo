class User < ActiveRecord::Base
  attr_accessible :ids, :screen_name, :name, :location, :sex,  :city, :province, :description, :profile_image_url, :followers_count, :friends_count, :statuses_count
end
