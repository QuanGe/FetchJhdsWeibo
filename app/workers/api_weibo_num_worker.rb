require "open-uri"
require 'net/http'
require 'json'

class ApiWeiboNumWorker
  include Sidekiq::Worker

  def perform(sids)

  puts "===============开始获取微博数目=#{sids}====================="

    urlstr = "https://api.weibo.com/2/statuses/count.json?ids=#{sids}&access_token=#{Settings.weibo.api_access_token}"
    urlstr = URI.escape(urlstr)
    url = URI.parse(urlstr)
    http = Net::HTTP.new(url.host, url.port)
    if url.scheme == 'https'
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http.use_ssl = true
    end
    request = Net::HTTP::Get.new(url.request_uri)
    request['Content-Type'] = 'application/x-www-form-urlencoded'
    resp = http.start {|http|
      http.request(request)
    }

    if [201,200,204].include? resp.code.to_i
      json_temp_str = JSON.parse(resp.body)
      json_temp_str.each do |weibo|
        id = weibo["id"]
        comments = weibo["comments"]
        reposts = weibo["reposts"]
        attitudes = weibo["attitudes"]
        w = Status.find_by_ids(id.to_s)
        w.repost_count = reposts
        w.comments_count = comments
        w.attitudes_count = attitudes
        w.save
      end

      puts "==========获取微博数目成功====#{sids}=================="
      Weibo::Logger.info("=========获取微博数目成功=====#{sids}=================")
    else
      puts "========获取微博数目失败:#{resp.code.to_s}==#{resp.body}=======#{sids}============="
      Weibo::Logger.info("========获取微博数目失败=#{resp.body}===========#{sids}==========")
    end

  end
end