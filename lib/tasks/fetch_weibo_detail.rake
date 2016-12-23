# coding: utf-8

namespace :weibo do
  desc "fetch weibo pic and save into mysql"
  task :fetch_weibo_detail => :environment do
    Weibo::WeiboService.fetch_weibo_pics
  end
end



