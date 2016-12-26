# encoding: utf-8

User.delete_all
Status.delete_all

# def user_params
#   params.require(:User).permit(:username, :email, :password, :password_confirmation)
# end
def fetch_from_github
  urlstr = "http://quangelab.com/images/jhds/weibo/weibo_num.txt"
  urlstr = URI.escape(urlstr)
  url = URI.parse(urlstr)
  http = Net::HTTP.new(url.host, url.port)
  request = Net::HTTP::Get.new(url.request_uri)
  resp = http.start {|http|
    http.request(request)
  }

  if(resp.code.to_s == "200")
    fetch_every_page(0,resp.body.to_i)
  end


end

def fetch_every_page(page,all)
  urlstr = "http://quangelab.com/images/jhds/weibo/weibo_#{page}.txt"
  urlstr = URI.escape(urlstr)
  url = URI.parse(urlstr)
  http = Net::HTTP.new(url.host, url.port)
  request = Net::HTTP::Get.new(url.request_uri)
  resp = http.start {|http|
    http.request(request)
  }

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

      puts " #{status['nickName']} **** #{status['text']}"
      Status.new(ids:status['idstr'],text:status['text'],pic_ids:ids,user_ids:status['userId'],created_at_time:status['created_timestamp'],pic_mul:false).save
      unless (User.find_by_ids(status['userId']).present?)
        User.new(ids:status['userId'],screen_name:status['nickName'],profile_image_url:status['userIcon']).save
      end

    end
  end

  if(page < all - 1)
    page = page + 1
    fetch_every_page(page,all)
  end
end

fetch_from_github

# # 添加高敏感词
# file = File.open(File.join(Rails.root,"db/fixtures", "highs.txt"), "r")
# file.each do |line|
#   Word.new(text: line.strip, level: 2).save
# end
# file.close
#
# # 添加低敏感词
# file = File.open(File.join(Rails.root,"db/fixtures", "lows.txt"), "r")
# file.each do |line|
#   Word.new(text: line.strip, level: 1).save
# end
# file.close