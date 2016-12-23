# coding: utf-8

namespace :weibo do
  desc "fetch weibo and save into mysql"
  task :fetch_users_weibo => :environment do
    Weibo::WeiboService.fetch_weibos(true)
  end
end



