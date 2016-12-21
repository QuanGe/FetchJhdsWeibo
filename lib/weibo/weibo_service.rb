# coding: utf-8

require 'nokogiri'
require "open-uri"
require 'uri'
require "ropencc"
module Weibo
  class WeiboService
    class << self

      def fetch_weibos_with_up(uid,page,quick)
        Weibo::Logger.info("Action" => "正在获取用户#{uid}的第#{page}页的数据")
        url = URI.encode("http://tw.weibo.com/#{uid}/p/#{page}")
        doc = Nokogiri::HTML(open(url))
        weibos = doc.xpath('//div[contains(@class, "weibo_status div_shadow")]').select{|weibo| (weibo['uid'].present?) && (weibo.at_css(".weibo_text").at_css("p").text.include? "#簡畫大師#")}
        user = doc.at_css("#mPic").at_css("img")
        pagenum = doc.at_css(".pgTxt").text.split("共").last.split("页").first


        nickName =  Ropencc.conv('tw2s.json', user['alt'])
        userIcon = user['src']
        weibos.each  do |weibo|
          idstr = weibo['id']
          img = weibo.at_css(".weibo_img")
          imgMulTag = weibo.at_css(".tip_photo")
          imgNum = imgMulTag['class'].include?("block")

          original_pic = img.present? ? img['src'] : ""
          text = Ropencc.conv('tw2s.json',weibo.at_css(".weibo_text").at_css("p").text.strip)
          created_time = weibo.at_css(".datetime_stamp").text
          created_timestamp = (Time.parse(created_time).to_f * 1000 ).to_i
          Weibo::Logger.info("==#{imgNum ? "多图" : "单图"}=#{page}/#{pagenum}====nickName:#{nickName},userIcon:#{userIcon},idstr:#{idstr},original_pic:#{original_pic},text:#{text},created_timestamp:#{created_timestamp}")
        end
        if(page.to_i < pagenum.to_i && !quick)
          fetch_weibos_with_up(uid,page.to_i + 1,quick)
        end

      end

      def fetch_weibos_by_user(uid,quick)
        fetch_weibos_with_up(uid,1,quick)
      end

      def fetch_weibos(quick)
        users = Settings.weibo.user_ids
        users.each do |user_id|
          fetch_weibos_by_user(user_id,quick)
        end
      end



    end
  end
end
