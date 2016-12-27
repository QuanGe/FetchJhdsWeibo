# coding: utf-8
require 'open3'
namespace :weibo do
  desc "if quangelab project some thing update ,push the code"
  task :push_git_hub => :environment do
    TwWeiboPushWorker.perform_async
  end
end