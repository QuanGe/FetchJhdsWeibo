# coding: utf-8

require "open-uri"
require 'net/http'
require 'json'

class ApiWeiboFavoritesWorker
  include Sidekiq::Worker
  sidekiq_options retry: false
  def perform
    urlstr = "https://api.weibo.com/2/favorites.json?access_token=#{Settings.weibo.api_access_token}"
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

      Weibo::Logger.info("=========获取收藏列表成功======================")
      json_temp_str = JSON.parse(resp.body)
      if json_temp_str["favorites"].present?

        json_temp_str["favorites"].select{|weibo| weibo["status"]["pic_urls"].present? && weibo["status"]["pic_urls"].size ==1 && (weibo["status"]["user"]["following"] || weibo["status"]["text"].include?("简画大师"))}.each do |weibo|

          text = weibo["status"]["text"].gsub(/<\/?.*?>/, "")
          low_words, high_words = Word.match(text)
          if !low_words.present? && !high_words.present? && Status.find_by_ids(weibo["status"]["idstr"]).blank?
            puts weibo["status"]["idstr"]+"===||-----------------||=="+text
            unless User.find_by_ids(weibo["status"]["user"]["idstr"]).present?
              puts "新用户===||-----------------||==#{weibo["status"]["user"]["screen_name"]}"
              user_ids = weibo["status"]["user"]["idstr"]
              user_screen_name= weibo["status"]["user"]["screen_name"]
              user_profile_image_url= weibo["status"]["user"]["profile_image_url"]
              user_location =weibo["status"]["user"]["location"]
              user_description =weibo["status"]["user"]["description"]
              user_sex = (weibo["status"]["user"]["gender"] == "f")
              user_followers_count = weibo["status"]["user"]["followers_count"]
              user_friends_count = weibo["status"]["user"]["friends_count"]
              user_statuses_count = weibo["status"]["user"]["statuses_count"]
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

            ApiWeiboCommentWorker.perform_async(weibo["status"]["user"]["idstr"],weibo["status"]["idstr"])
            Emailer.mailer("zhang_ru_quan@163.com",text,weibo["status"]["user"]["screen_name"]).deliver_now
            Status.create(ids:weibo["status"]["idstr"],
                          text:text,
                          created_at_time:(Time.parse(weibo["status"]["created_at"]).to_f).to_i,
                          pic_ids:weibo["status"]["pic_urls"][0]["thumbnail_pic"].split("/").last.split(".").first,
                          user_ids:weibo["status"]["user"]["idstr"],
                          repost_count:weibo["status"]["reposts_count"],
                          comments_count:weibo["status"]["comments_count"],
                          attitudes_count:weibo["status"]["attitudes_count"],
                          pic_mul:false


            )

          end

        end
      end



    else
      puts "===========获取收藏列表失败==#{resp.body}===================="
      Weibo::Logger.info("========获取收藏列表失败======================")
    end
  end
end