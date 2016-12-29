# coding: utf-8

require "open-uri"
require 'net/http'
require 'json'

class ApiWeiboCommentWorker
  include Sidekiq::Worker

  def perform(uid,sid)
    u = User.find_by_ids(uid)
    lihai =  u.sex ? "姐" : "哥"
    puts "===============开始评论微博#{sid}======================"
    comment = "厉害了word#{lihai},#{u.screen_name}画的不错，加油！已于#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}收录到简画大师App数据中，如果在使用时遇到问题可以私信我。"
    urlstr = "https://api.weibo.com/2/comments/create.json?id=#{sid}&comment=#{comment}&access_token="
    urlstr = URI.escape(urlstr)
    url = URI.parse(urlstr)
    http = Net::HTTP.new(url.host, url.port)
    if url.scheme == 'https'
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http.use_ssl = true
    end

    request = Net::HTTP::Post.new(url.request_uri)
    request['Content-Type'] = 'application/x-www-form-urlencoded'
    resp = http.start {|http|
      http.request(request)
    }

    if [201,200,204].include? resp.code.to_i
      puts "==========#{sid}=====评论成功======================"
      Weibo::Logger.info("=========#{sid}======评论成功======================")
    else
      puts "========#{sid}=======评论失败:#{resp.code.to_s}==#{resp.body}===================="
      Weibo::Logger.info("========#{sid}=======评论失败======================")
    end

  end
end