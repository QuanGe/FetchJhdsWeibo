# coding: utf-8

namespace :weibo do
  desc "fetch weibo and save into mysql"
  task :fetch_api_friends_weibo => :environment do
    Weibo::WeiboService.fetch_weibo_friends_weibos
  end
end



