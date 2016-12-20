# coding: utf-8

# require 'nokogiri'
# require "open-uri"
# require 'uri'

module Weibo
  class WeiboService
    class << self

      def fetch_weibos(uid,page)
        Weibo::Logger.info("Action" => "正在获取用户#{uid}的第#{page}页的数据")
        doc = Nokogiri::HTML(open("http://tw.weibo.com/#{uid}/p/#{page}"))
        weibos = doc.xpath('//div[contains(@class, "weibo_status div_shadow")]').select{|div| div['id'].present?}
        user = doc.at_css("#mPic").at_css("img")
        nickName = user['alt']
        userIcon = user['src']

        weibos.each  do |weibo|
          idstr = weibo['id']
          original_pic = weibo.at_css(".weibo_img lazy")['src']
          text = weibo.at_css(".weibo_text weibo_content").at_css("p").text
          created_timestamp = weibo.at_css(".datetime_stamp").text
          puts "nickName:#{nickName},userIcon:#{userIcon},idstr:#{idstr},original_pic:#{original_pic},text:#{text},created_timestamp:#{created_timestamp}"
        end
      end

      def fetch_weibos_by_user(uid)
        fetch_weibos(uid,1)
      end


    end
  end
end
