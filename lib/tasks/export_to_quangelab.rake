# coding: utf-8

namespace :weibo do
  desc "export my sql weibo data to quangelab project"
  task :export_to_quangelab => :environment do
    Weibo::WeiboService.export_data
  end
end