require 'nokogiri'
require "open-uri"
require 'uri'
require "ropencc"

class TwWeiboPicWorker
  include Sidekiq::Worker

  def perform(uid,sid)
    #Weibo::Logger.info("Action" => "正在获取用户#{uid}的#{sid}详情页的数据")
    url = URI.encode("http://tw.weibo.com/#{uid}/#{sid}")
    doc = Nokogiri::HTML(open(url))
    imgs = doc.xpath('//div[contains(@class, "carousel carousel-navigation")]').css("img")
    #Weibo::Logger.info("Action" => "获取了共#{imgs.size}个图片的数据")

    imgsIds = ""
    imgs.each do |img|
      imgsIds = imgsIds + img["src"].split("/").last.split(".").first
      imgsIds = imgsIds +  ((img == imgs.last ) ? "" : ",")
    end

    if Status.find_by_ids(sid).present?

      weibo = Status.find_by_ids(sid)
      weibo.pic_ids = imgsIds
      weibo.pic_mul = false
      weibo.save
      #puts "##############{sid}##########{imgsIds}################"

    end

  end

end