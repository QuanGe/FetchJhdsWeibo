require 'open3'

class TwWeiboExportWorker
  include Sidekiq::Worker
  sidekiq_options retry: false
  def perform
    #Emailer.mailer("zhang_ru_quan@163.com","测试部署发邮件","简画大师").deliver_now
    export_data(git_status())

  end

  def export_data (behind)
    puts "当前代码是不是比较落后：#{behind}"
    Weibo::Logger.info("当前代码是不是比较落后：#{behind}")
    if(behind )
      timestr = Time.now.strftime("%Y%m%d%H%M%S")
      subcmd = "cd #{Settings.server.github_local_pos} && cd ../../.. && git pull "
      puts " ========#{timestr}=======开始更新来自github的微博数据#{subcmd}============="
      Weibo::Logger.info("========#{timestr}=======开始更新来自github的微博数据#{subcmd}=============")
      Open3.popen3(subcmd) do |stdin, stdout, stderr, wait_thr|
        timestr = Time.now.strftime("%Y%m%d%H%M%S")
        puts " ========#{timestr}=======导出数据库中数据============="
        Weibo::Logger.info("========#{timestr}=======导出数据库中数据=============")
        Weibo::WeiboService.sync_data
        Weibo::WeiboService.export_data
      end
    else
      Weibo::WeiboService.export_data
      timestr = Time.now.strftime("%Y%m%d%H%M%S")
      puts "==============#{timestr}=============github服务器没有更新直接导出数据"
      Weibo::Logger.info("==============#{timestr}=============github服务器没有更新直接导出数据")
    end

  end
  def git_status
    cd = "cd #{Settings.server.github_local_pos} && cd ../../.. && git fetch && git status "
    behind = false
    Open3.popen3(cd) do |stdin, stdout, stderr, wait_thr|
      stdout.each_line { |line|
        if (line.to_s.include?"Your branch is behind")
          behind =true
          puts line.to_s
          Weibo::Logger.info("#{line.to_s}")
        end

      }
    end

    return behind
  end
end