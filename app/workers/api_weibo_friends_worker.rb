# coding: utf-8

require "open-uri"
require 'net/http'
require 'json'

class ApiWeiboFriendsWorker
  include Sidekiq::Worker
  sidekiq_options retry: false
  def perform
    urlstr = "https://api.weibo.com/2/statuses/friends_timeline.json?access_token=#{Settings.weibo.api_access_token}&base_app=1&feature=2"
    urlstr = URI.escape(urlstr)
    url = URI.parse(urlstr)
    http = Net::HTTP.new(url.host, url.port)
    if url.scheme == 'https'
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http.use_ssl = true
    end

    request = Net::HTTP::Get.new(url.request_uri)
    #request['Content-Type'] = 'application/x-www-form-urlencoded'
    resp = http.start {|http|
      http.request(request)
    }

    if [201,200,204].include? resp.code.to_i

      Weibo::Logger.info("=========获取我关注的人发表的简画大师列表成功======================")
      json_temp_str = JSON.parse(resp.body)
      if json_temp_str["statuses"].present?

        json_temp_str["statuses"].each do |weibo|

          text = weibo["text"].gsub(/<\/?.*?>/, "")
          low_words, high_words = Word.match(text)
          if !low_words.present? && !high_words.present? && Status.find_by_ids(weibo["idstr"]).blank? && weibo["retweeted_status"].blank?
            puts weibo["idstr"]+"===||-----------------||=="+text
            unless User.find_by_ids(weibo["user"]["idstr"]).present?
              puts "新用户===||-----------------||==#{weibo["user"]["screen_name"]}"
              user_ids = weibo["user"]["idstr"]
              user_screen_name= weibo["user"]["screen_name"]
              user_profile_image_url= weibo["user"]["profile_image_url"]
              user_location =weibo["user"]["location"]
              user_description =weibo["user"]["description"]
              user_sex = (weibo["user"]["gender"] == "f")
              user_followers_count = weibo["user"]["followers_count"]
              user_friends_count = weibo["user"]["friends_count"]
              user_statuses_count = weibo["user"]["statuses_count"]
              User.create(ids:user_ids,
                          screen_name:user_screen_name,
                          location:user_location,
                          description:user_description,
                          sex:user_sex,
                          profile_image_url:user_profile_image_url,
                          followers_count:user_followers_count,
                          friends_count:user_friends_count,
                          statuses_count:user_statuses_count)
            end

            ApiWeiboCommentWorker.perform_async(weibo["user"]["idstr"],weibo["idstr"])
            Emailer.mailer("zhang_ru_quan@163.com",text,weibo["user"]["screen_name"]).deliver_now
            Status.create(ids:weibo["idstr"],
                          text:text,
                          created_at_time:(Time.parse(weibo["created_at"]).to_f).to_i,
                          pic_ids:weibo["pic_urls"][0]["thumbnail_pic"].split("/").last.split(".").first,
                          user_ids:weibo["user"]["idstr"],
                          repost_count:weibo["reposts_count"],
                          comments_count:weibo["comments_count"],
                          attitudes_count:weibo["attitudes_count"],
                          pic_mul:false


            )

          end

        end
      end



    else
      puts "===========获取我关注的人发表的简画大师列表失败==#{resp.body}===================="
      Weibo::Logger.info("========获取我关注的人发表的简画大师列表列表失败======================")
    end
  end
end