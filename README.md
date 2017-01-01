ubuntu 14.04LTS
sudo apt-get purge mysql-server-5.5 mysql-client-5.5
sudo apt-get autoremove
sudo apt-get install mysql-server-5.5 mysql-client-5.5 默认安装5.5.53
sudo apt-get install redis-server
sudo apt-get install libmysqlclient-dev

gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
curl -L https://raw.githubusercontent.com/wayneeseguin/rvm/master/binscripts/rvm-installer | bash -s stable
source ~/.rvm/scripts/rvm
rvm install 2.1.8
gem sources --add https://gems.ruby-china.org/ --remove https://rubygems.org/
gem install bundler
gem install rails

sudo apt-get install node.js

 ssh-keygen -t rsa -b 4096 -C "zhang_ru_quan@163.com"
sudo apt-get install git



抓取微博上的简画大师数据，并分发到服务器

抓包微博相关参考文章
html解析
[http://james1239090-blog.logdown.com/](http://james1239090-blog.logdown.com/)

微博基本数据采集方法
[http://james1239090-blog.logdown.com/](http://www.jianshu.com/p/cdc9db5b6bd8)

繁体转简体
[https://github.com/psli/ropencc](https://github.com/psli/ropencc)

mysql需要插入表情，本人用的5.5.49版本
[https://ruby-china.org/topics/24693](https://ruby-china.org/topics/24693)

sidekiq 
[http://www.cnblogs.com/richard1234/p/3829074.html](http://www.cnblogs.com/richard1234/p/3829074.html)

crontab
[http://blog.sina.com.cn/s/blog_60b45f2301011hqp.html](http://blog.sina.com.cn/s/blog_60b45f2301011hqp.html)

crontab export_to_quangelab
crontab -r
crontab -e
crontab -l
sudo chmod 777 /Users/Shared/GitHub/FetchJhdsWeibo/crontab/export_to_quangelab.sh

邮件

[http://guides.ruby-china.org/action_mailer_basics.html](http://guides.ruby-china.org/action_mailer_basics.html)
[https://ruby-china.org/topics/8918](https://ruby-china.org/topics/8918)
[https://ruby-china.org/topics/8233](https://ruby-china.org/topics/8233)

查看rvm 安装到哪个文件夹 echo $GEM_PATH

使用步骤

设置数据库
bundle exec rake db:drop:all

bundle exec rake db:create:all

bundle exec rake db:migrate

rake database:convert_to_utf8mb4

初始化数据

bundle exec rake db:seed_fu

启动sidekiq

bundle exec sidekiq -C config/sidekiq.yml

停止sidekiq
kill -s 9 $(pgrep side)


启动redis

redis-server --port 6379 &


查看sidekiq执行情况

http://localhost:3000/sidekiq/queues

清除redis 里面的内容
redis-cli flushall









