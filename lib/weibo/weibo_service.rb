# coding: utf-8

require 'net/http'
require 'nokogiri'
require "open-uri"
require 'uri'
require "ropencc"
module Weibo
  class WeiboService
    class << self

      def fetch_weibos(quick)
        timestr = Time.now.strftime("%Y%m%d%H%M%S")
        puts "======开始获取所有用户微博数据" + timestr
        tmp = 1
        User.all.each do |user|
          tmp = tmp + 5
          TwWeiboListWorker.perform_in(tmp.seconds,user.ids,1,quick)
          # if user.ids == "2216172153"
          #   TwWeiboListWorker.perform_in(tmp.seconds,user.ids,1,quick)
          # end

        end
        puts "---------------------------"
      end

      def fetch_weibo_favorites
        ApiWeiboFavoritesWorker.perform_async
      end

      def fetch_weibo_friends_weibos
        ApiWeiboFriendsWorker.perform_async
      end

      def fetch_weibo_pics()
        timestr = Time.now.strftime("%Y%m%d%H%M%S")
        puts "======开始获取微博图片数据" + timestr
        weibos = Status.select{ |weibo| weibo.pic_mul == true }
        tmp = 1
        weibos.each do |weibo|
          tmp = tmp + 5
          TwWeiboPicWorker.perform_in(tmp.seconds,weibo.user_ids,weibo.ids)
        end
        puts "---------------------------"
      end

      def comment_every_weibo()
        timestr = Time.now.strftime("%Y%m%d%H%M%S")
        puts "======开始评论每条微博" + timestr
        weibos = Status.select{ |weibo| weibo.ids != "4056967611286590" && weibo.pic_ids != ""}
        tmp = 1
        weibos.each do |weibo|
          tmp = tmp + 30
          #ApiWeiboCommentWorker.perform_in(tmp.seconds,weibo.user_ids,weibo.ids)
        end
        puts "---------------------------"
      end

      def fetch_weibo_num
        puts "===============开始获取微博数目======================"
        idsArray = Array.new
        ids = ""
        index = 0
        Status.all.each  do |weibo|
          ids = ids + weibo.ids
          ids = ids + (index == (Settings.server.page_item_num - 1) ? "" : ",")
          if index == (Settings.server.page_item_num - 1)
            idsArray.push(ids)
            ids = ""
          end

          index = (index == (Settings.server.page_item_num - 1)) ? 0 : index +1
        end
        if(ids != "")
          ids = ids[0,ids.length-1]
          idsArray.push(ids)
        end

        tmp = 1
        idsArray.each do |ids|
          tmp = tmp + 10
          ApiWeiboNumWorker.perform_in(tmp.seconds,ids)
        end

      end


      def fetch_from_github(sync)
        urlstr = "http://quangelab.com/images/jhds/weibo/weibo_num.txt"
        urlstr = URI.escape(urlstr)
        url = URI.parse(urlstr)
        http = Net::HTTP.new(url.host, url.port)
        request = Net::HTTP::Get.new(url.request_uri)
        resp = http.start {|http|
          http.request(request)
        }

        if(resp.code.to_s == "200")
          fetch_every_page(resp.body.to_i-1,resp.body.to_i,sync)
        end


      end

      def fetch_every_page(page,all,sync)
        urlstr = "http://quangelab.com/images/jhds/weibo/weibo_#{page}.txt"
        urlstr = URI.escape(urlstr)
        url = URI.parse(urlstr)
        http = Net::HTTP.new(url.host, url.port)
        request = Net::HTTP::Get.new(url.request_uri)
        resp = http.start {|http|
          http.request(request)
        }

        not_in_mysql = true

        if(resp.code.to_s == "200")
          json_temp_str = JSON.parse(resp.body)
          json_temp_str.each do |status|
            ids = ""
            status['pic_ids'].each do |id|
              ids = ids+id
              if id != status['pic_ids'].last
                ids = ids+","
              end
            end


            if sync
              not_in_mysql = Status.find_by_ids(status['idstr']).blank?

            end

            if not_in_mysql
              puts " #{status['nickName']} **** #{status['text']}"
              Weibo::Logger.info("#{status['nickName']} **** #{status['text']}")
              Status.new(ids:status['idstr'],text:status['text'],pic_ids:ids,user_ids:status['userId'],created_at_time:status['created_timestamp'],pic_mul:false).save
              unless (User.find_by_ids(status['userId']).present?)
                User.new(ids:status['userId'],screen_name:status['nickName'],profile_image_url:status['userIcon']).save
              end
            end


          end
        end

        if(page >0 )
          page = page -1
          puts "=======================下面是第#{page}页================"
          Weibo::Logger.info("=======================下面是第#{page}页================")
          fetch_every_page(page,all,sync)
        end
      end



      def sync_data
        fetch_from_github(true)
      end

      def export_data
        timestr = Time.now.strftime("%Y%m%d%H%M%S")
        puts "======开始导出数据" + timestr
        tops = Status.find_by_sql("select * from (SELECT * FROM jhds_weibo_development.statuses  order by jhds_weibo_development.statuses.created_at_time desc) as a group by a.user_ids order by a.created_at_time desc ")
        allweibs = Status.order("created_at_time DESC")
        weibs = Array.new
        tops.each do |weibo|
            weibs.push(weibo)
        end
        allweibs.each do |weibo|
          if !(tops.include?weibo)
            weibs.push(weibo)
          end
        end


        index = 0
        page_num = weibs.size / Settings.server.page_item_num + (weibs.size % Settings.server.page_item_num == 0 ? 0 : 1)

        aFile = File.new("#{Settings.server.github_local_pos}weibo_num.txt","w")
        aFile.print page_num.to_s
        aFile.close

        page_index = 0

        strTmp = "["

        weibs.each do |weibo|

          text = weibo.text
          if weibo.text.include? "\n"
            text = weibo.text.gsub("\n","")
            #puts "=============已经替换 #{text}"
          end
          op = weibo.pic_ids == "" ? "" : "http://ww1.sinaimg.cn/large/#{weibo.pic_ids.split(",").first}.jpg"
          user = User.find_by_ids(weibo.user_ids)
          weiboStr = "{\"idstr\":\"#{weibo.ids}\",\"text\":\"#{text}\"
                    ,\"pic_ids\":#{weibo.pic_ids.split(",").to_s.to_s}
                    ,\"original_pic\":\"#{op}\",\"userIcon\":\"#{user.profile_image_url}\"
                    ,\"nickName\":\"#{user.screen_name}\",\"userId\":\"#{user.ids}\"
                    ,\"created_timestamp\":\"#{weibo.created_at_time}\"}"
          strTmp = strTmp + weiboStr

          strTmp = strTmp + (index == (Settings.server.page_item_num - 1) ? "]" : ",")
          if index == (Settings.server.page_item_num - 1)
            #puts "===========第#{page_num-page_index-1}页的数据====================="
            aFile = File.new("#{Settings.server.github_local_pos}weibo_#{page_num-page_index-1}.txt","w")
            aFile.print strTmp
            aFile.close
            #puts strTmp
            #puts "================================"
            strTmp = "["
            page_index = page_index + 1

          end


          index = (index == (Settings.server.page_item_num - 1)) ? 0 : index +1

        end

        if(strTmp != "[")
          #puts "===========第#{page_num-page_index-1}页的数据====================="
          strTmp = strTmp[0,strTmp.length-1]
          strTmp = strTmp +"]"
          aFile = File.new("#{Settings.server.github_local_pos}weibo_#{page_num-page_index-1}.txt","w")
          aFile.print strTmp
          aFile.close
          #puts strTmp
          #puts "================================"

        end

        puts "---------------------------"
      end

    end
  end
end
