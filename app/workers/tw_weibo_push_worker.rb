require 'open3'

class TwWeiboPushWorker
  include Sidekiq::Worker
  sidekiq_options retry: false
  def perform
    #Emailer.mailer("zhang_ru_quan@163.com","测试部署发邮件","简画大师").deliver_now
    pushCode(git_status())

  end

  def pushCode (subcmd)
    puts subcmd
    if(subcmd != "")
      timestr = Time.now.strftime("%Y%m%d%H%M%S")
      if (subcmd == "git add .")
        subcmd.concat(" && git commit -m 'update weibo data#{timestr}' && git pull && git push")
      end
      subcmd = "cd #{Settings.server.github_local_pos} && cd ../../.. && ".concat(subcmd)
      puts timestr+"开始上传微博数据#{subcmd}"
      Open3.popen3(subcmd) do |stdin, stdout, stderr, wait_thr|
        subcmd = ""
        stdout.each_line { |line|
          puts line
        }
        #puts "上传成功"
      end
    else
      puts "没有数据更新"

    end

  end
  def git_status
    cd = "cd #{Settings.server.github_local_pos} && cd ../../.. && git status "
    subcmd = ""
    Open3.popen3(cd) do |stdin, stdout, stderr, wait_thr|

      subcmd = ""
      stdout.each_line { |line|
        puts "line = #{line.to_s} 判断line =~ /[^\.]+\.[a-zA-Z0-9]+/ )的值为 #{(line.to_s =~ /[^\.]+\.[a-zA-Z0-9]+/ )} 并且subcmd=#{subcmd}"
        if (line.to_s =~ /[^\.]+\.[a-zA-Z0-9]+/ ) && (subcmd == "")
          subcmd.concat("git add .")
          puts line.to_s
        elsif (line.to_s.include?"to publish your local commits") && (subcmd == "")
          subcmd.concat("git push")
          puts line.to_s
        end

      }



    end

    return subcmd
  end
end