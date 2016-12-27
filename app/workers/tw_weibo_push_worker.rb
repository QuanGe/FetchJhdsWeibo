require 'open3'

class TwWeiboPushWorker
  include Sidekiq::Worker

  def perform

    pushCode(git_status())

  end

  def pushCode (subcmd)
    puts subcmd
    if(subcmd != "")
      timestr = Time.now.strftime("%Y%m%d%H%M%S")
      if (subcmd == "git add .")
        subcmd.concat(" && git commit -m 'update weibo data#{timestr}' && git pull --rebase && git push")
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
        if (!line.include?"On branch master") && (!line.include?" to unstage") && (!line.include?" update what will be committed") && (!line.include?"Your branch is up") && (!line.include?"Changes not staged") && (!line.include?"include in what will be committed") && (!line.include?"Untracked files") && (!line.include?"no changes added t") && (!line.include?"git checkout --")

          if(line.include?"modified:   ")
            if (subcmd == "")

              subcmd.concat("git add .")
              puts line
            end
          elsif(line.include?"new file:   ")
            if  (subcmd == "")

              subcmd.concat("git add .")
              puts line
            end
          elsif (line.include?".") && (subcmd == "") && !(line.include?"commits.") && !(line.include?"You are currently rebasing branch") && !(line.include?"Your branch is ahead of")
            subcmd.concat("git add .")
            puts line
          elsif (line.include?"to publish your local commits") && (subcmd == "")
            subcmd.concat("git push")

          end

        end

      }

      return subcmd

    end
  end
end