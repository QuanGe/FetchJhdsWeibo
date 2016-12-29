# coding: utf-8

namespace :weibo do
  desc "fetch weibo num and save into mysql"
  task :fetch_weibo_num => :environment do
    Weibo::WeiboService.fetch_weibo_num
  end
end



