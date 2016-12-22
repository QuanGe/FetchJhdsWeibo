# coding: utf-8

require 'nokogiri'
require "open-uri"
require 'uri'
require "ropencc"
module Weibo
  class WeiboService
    class << self

      def fetch_weibos(quick)
        tmp = 1
        User.all.each do |user|
          #tmp = tmp + 30
          TwWeiboListWorker.perform_async(user.ids,1,quick)
          # if user.ids == "2216172153"
          #   TwWeiboListWorker.perform_in(tmp.seconds,user.ids,1,quick)
          # end

        end
      end

      def export_data
        weibs = Status.order("created_at_time DESC")
        index = 0
        page_num = weibs.size / 10 + (weibs.size % 10 == 0 ? 0 : 1)

        aFile = File.new("#{Settings.server.github_local_pos}weibo_num.txt","w")
        aFile.print page_num.to_s
        aFile.close

        page_index = 0

        strTmp = "["
        weibs.each do |weibo|

          op = weibo.pic_ids == "" ? "" : "http://ww1.sinaimg.cn/large/#{weibo.pic_ids.split(",").first}.jpg"
          user = User.find_by_ids(weibo.user_ids)
          weiboStr = "{\"idstr\":\"#{weibo.ids}\",\"text\":\"#{weibo.text}\"
                    ,\"pic_ids\":#{weibo.pic_ids.split(",").to_s.to_s}
                    ,\"original_pic\":\"#{op}\",\"userIcon\":\"#{user.profile_image_url}\"
                    ,\"nickName\":\"#{user.screen_name}\",\"userId\":\"#{user.ids}\"
                    ,\"created_timestamp\":\"#{weibo.created_at_time}\"}"
          strTmp = strTmp + weiboStr

          strTmp = strTmp + (index == (Settings.server.page_item_num - 1) ? "]" : ",")
          if index == (Settings.server.page_item_num - 1)
            puts "================================"
            aFile = File.new("#{Settings.server.github_local_pos}weibo_#{page_num-page_index-1}.txt","w")
            aFile.print strTmp
            aFile.close
            puts strTmp
            puts "================================"
            strTmp = "["
            page_index = page_index + 1

          end

          index = (index == (Settings.server.page_item_num - 1)) ? 0 : index +1

        end

      end

    end
  end
end
