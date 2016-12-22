class Status < ActiveRecord::Base
  attr_accessible :ids, :text,:created_at_time, :pic_ids,:user_ids, :repost_count,:comments_count, :attitudes_count,:pic_mul
end
