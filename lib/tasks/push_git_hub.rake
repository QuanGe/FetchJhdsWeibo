# coding: utf-8
require 'open3'
namespace :weibo do
  desc "if quangelab project some thing update ,push the code"
  task :push_git_hub => :environment do

    def pushCode
      if($subcmd != "")
        timestr = Time.now.strftime("%Y%m%d%H%M%S")
        $subcmd.concat(" && git commit -m 'update weibo data#{timestr}' && git pull --rebase && git push")
        $subcmd = "cd #{Settings.server.github_local_pos} && cd ../../.. && ".concat($subcmd)
        puts timestr+"开始上传微博数据#{$subcmd}"
        Open3.popen3($subcmd) do |stdin, stdout, stderr, wait_thr|
          $subcmd = ""
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
      Open3.popen3(cd) do |stdin, stdout, stderr, wait_thr|

        $subcmd = ""
        stdout.each_line { |line|
          if (!line.include?"On branch master") && (!line.include?" to unstage") && (!line.include?" update what will be committed") && (!line.include?"Your branch is up") && (!line.include?"Changes not staged") && (!line.include?"include in what will be committed") && (!line.include?"Untracked files") && (!line.include?"no changes added t") && (!line.include?"git checkout --")

            if(line.include?"modified:   ")
              if ($subcmd == "")
                $subcmd.concat("git add .")
              end
            elsif(line.include?"new file:   ")
              if  ($subcmd == "")
                $subcmd.concat("git add .")
              end
            elsif (line.include?".") && ($subcmd == "")
              $subcmd.concat("git add .")
            else

            end

          end

        }


      end
    end

    git_status()
    pushCode()




  end
end