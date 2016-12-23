require 'nokogiri'
require "open-uri"
require 'uri'
require "ropencc"

class TwWeiboListWorker
  include Sidekiq::Worker

  def perform(uid,page,quick)
    #Weibo::Logger.info("Action" => "正在获取用户#{uid}的第#{page}页的数据")
    url = page == 1 ? URI.encode("http://tw.weibo.com/#{uid}/") : URI.encode("http://tw.weibo.com/#{uid}/p/#{page}")
    doc = Nokogiri::HTML(open(url))
    weibos = doc.xpath('//div[contains(@class, "weibo_status div_shadow")]').select{|weibo| (weibo['uid'].present?) && (weibo.css(".weibo_text").size == 1) &&(weibo.css("div").select{|content| content['uid'] == uid}.first.at_css("p").at_css("a")['title'].strip.include? Settings.weibo.filter)}
    #Weibo::Logger.info("Action" => "共#{weibos.size}条获取了的数据")
    user = doc.at_css("#mPic").at_css("img")
    nickName =  Ropencc.conv('tw2s.json', user['alt'])
    userIcon = user['src']
    userDes = Ropencc.conv('tw2s.json',doc.at_css("#mProfile").at_css(".intro").text)
    userSex = doc.at_css("#mProfile").css("span").first.text
    userLoc = Ropencc.conv('tw2s.json',doc.at_css("#mProfile").css("span").last.text)
    userPublishNum = doc.at_css(".publishNum").at_css("strong").text
    userFollowNum = doc.at_css(".followNum").at_css("strong").text
    userFansNum = doc.at_css(".fansNum").at_css("strong").text

    if (User.find_by_ids(uid).present?)
      u = User.find_by_ids(uid)
      u.location = userLoc
      u.screen_name = nickName
      u.description = userDes
      u.sex = (userSex == "女")
      u.followers_count = userFansNum.to_i
      u.friends_count = userFollowNum.to_i
      u.statuses_count = userPublishNum.to_i
      u.save
    end


    if doc.at_css(".pgTxt").present?
      pagenum = doc.at_css(".pgTxt").text.split("共").last.split("页").first

      weibos.each  do |weibo|

        idstr = weibo['id']
        img = weibo.at_css(".weibo_img")
        imgMulTag = weibo.at_css(".tip_photo")
        imgNum = imgMulTag.present? ? imgMulTag['class'].include?("block") : true
        original_pic = img.present? ? img['data-original'] : ""
        text = Ropencc.conv('tw2s.json',weibo.css("div").select{|content| content['uid'] == uid}.first.at_css("p").at_css("a")['title'].strip)
        text = text.gsub('\n','')
        created_time = weibo.at_css(".datetime_stamp").text
        created_timestamp = (Time.parse(created_time).to_f).to_i
        unless Status.find_by_ids(idstr).present?
          Status.new(ids:idstr,text:text,pic_ids:(original_pic == "" ) ? "" : original_pic.split("/").last.split(".").first ,user_ids:"#{uid}",created_at_time:created_timestamp,pic_mul:imgNum).save
          #Weibo::Logger.info("*********新获取数据==#{imgNum ? "多图" : "单图"}=#{page}/#{pagenum}====user_id:#{uid},nickName:#{nickName},userIcon:#{userIcon},idstr:#{idstr},original_pic:#{original_pic},text:#{text},created_timestamp:#{created_timestamp}")
        end
      end
      if(!quick && (page == 1 ) && pagenum.to_i > 1)
        for i in 2..pagenum.to_i
          TwWeiboListWorker.perform_in(20.seconds*(i),uid,i,quick)
        end
      end

    end

  end
end