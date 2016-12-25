# coding: utf-8

require 'nokogiri'
require "open-uri"
require 'uri'
require "ropencc"
module Weibo
  class WeiboService
    class << self

      def fetch_weibos(quick)
        timestr = Time.now.strftime("%Y%m%d%H%M%S")
        puts "======开始获取所有用户微博数据" + timestr
        tmp = 1
        User.all.each do |user|
          #tmp = tmp + 30
          TwWeiboListWorker.perform_async(user.ids,1,quick)
          # if user.ids == "2216172153"
          #   TwWeiboListWorker.perform_in(tmp.seconds,user.ids,1,quick)
          # end

        end
        puts "---------------------------"
      end

      def fetch_weibo_pics()
        timestr = Time.now.strftime("%Y%m%d%H%M%S")
        puts "======开始获取微博图片数据" + timestr
        weibos = Status.select{ |weibo| weibo.pic_mul == true }
        weibos.each do |weibo|
          TwWeiboPicWorker.perform_async(weibo.user_ids,weibo.ids)
        end
        puts "---------------------------"
      end

      def export_data
        timestr = Time.now.strftime("%Y%m%d%H%M%S")
        puts "======开始导出数据" + timestr
        weibs = Status.order("created_at_time DESC")
        index = 0
        page_num = weibs.size / Settings.server.page_item_num + (weibs.size % Settings.server.page_item_num == 0 ? 0 : 1)

        aFile = File.new("#{Settings.server.github_local_pos}weibo_num.txt","w")
        aFile.print page_num.to_s
        aFile.close

        page_index = 0

        strTmp = "["

        weibs.each do |weibo|

          text = weibo.text
          if weibo.text.include? "\n"
            text = weibo.text.gsub("\n","")
            #puts "=============已经替换 #{text}"
          end
          op = weibo.pic_ids == "" ? "" : "http://ww1.sinaimg.cn/large/#{weibo.pic_ids.split(",").first}.jpg"
          user = User.find_by_ids(weibo.user_ids)
          weiboStr = "{\"idstr\":\"#{weibo.ids}\",\"text\":\"#{text}\"
                    ,\"pic_ids\":#{weibo.pic_ids.split(",").to_s.to_s}
                    ,\"original_pic\":\"#{op}\",\"userIcon\":\"#{user.profile_image_url}\"
                    ,\"nickName\":\"#{user.screen_name}\",\"userId\":\"#{user.ids}\"
                    ,\"created_timestamp\":\"#{weibo.created_at_time}\"}"
          strTmp = strTmp + weiboStr

          strTmp = strTmp + (index == (Settings.server.page_item_num - 1) ? "]" : ",")
          if index == (Settings.server.page_item_num - 1)
            #puts "===========第#{page_num-page_index-1}页的数据====================="
            aFile = File.new("#{Settings.server.github_local_pos}weibo_#{page_num-page_index-1}.txt","w")
            aFile.print strTmp
            aFile.close
            #puts strTmp
            #puts "================================"
            strTmp = "["
            page_index = page_index + 1

          end


          index = (index == (Settings.server.page_item_num - 1)) ? 0 : index +1

        end

        if(strTmp != "[")
          #puts "===========第#{page_num-page_index-1}页的数据====================="
          strTmp = strTmp[0,strTmp.length-1]
          strTmp = strTmp +"]"
          aFile = File.new("#{Settings.server.github_local_pos}weibo_#{page_num-page_index-1}.txt","w")
          aFile.print strTmp
          aFile.close
          #puts strTmp
          #puts "================================"

        end

        puts "---------------------------"
      end

    end
  end
end
