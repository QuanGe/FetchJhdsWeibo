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
        weibos = doc.xpath('//div[contains(@class, "weibo_status div_shadow")]').select{|weibo| (weibo['uid'].present?) && (weibo.css(".weibo_text").size == 1) &&(weibo.css("div").select{|content| content['uid'] == uid}.first.at_css("p").at_css("a")['title'].strip.include? "#簡畫大師#")}
        user = doc.at_css("#mPic").at_css("img")
        pagenum = doc.at_css(".pgTxt").text.split("共").last.split("页").first


        nickName =  Ropencc.conv('tw2s.json', user['alt'])
        userIcon = user['src']
        weibos.each  do |weibo|
          idstr = weibo['id']
          img = weibo.at_css(".weibo_img")
          imgMulTag = weibo.at_css(".tip_photo")
          imgNum = imgMulTag.present? ? imgMulTag['class'].include?("block") : true
          original_pic = img.present? ? img['data-original'] : ""
          text = Ropencc.conv('tw2s.json',weibo.css("div").select{|content| content['uid'] == uid}.first.at_css("p").at_css("a")['title'].strip)
          created_time = weibo.at_css(".datetime_stamp").text
          created_timestamp = (Time.parse(created_time).to_f * 1000 ).to_i
          unless Status.find_by_ids(idstr).present?
            #Status.new(ids:idstr,text:text,pic_ids:(original_pic == "" ) ? "" : original_pic.split("/").last.split(".").first ,user_ids:"#{uid}",created_at_time:created_timestamp,pic_mul:imgNum).save
            Weibo::Logger.info("*********新获取数据==#{imgNum ? "多图" : "单图"}=#{page}/#{pagenum}====user_id:#{uid},nickName:#{nickName},userIcon:#{userIcon},idstr:#{idstr},original_pic:#{original_pic},text:#{text},created_timestamp:#{created_timestamp}")

          end


        end
        if(page.to_i < pagenum.to_i && !quick)
          sleep 5000
          fetch_weibos_with_up(uid,page.to_i + 1,quick)
        end

      end

      def fetch_weibos_by_user(uid,quick)
        fetch_weibos_with_up(uid,1,quick)
      end

      def fetch_weibos(quick)
        User.all.each do |user|
          fetch_weibos_by_user(user.ids,quick)
        end
      end



    end
  end
end
