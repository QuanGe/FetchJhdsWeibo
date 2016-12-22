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

使用步骤
设置数据库
bundle exec rake db:drop:all
bundle exec rake db:create:all
bundle exec rake db:migrate
rake database:convert_to_utf8mb4
初始化数据
bundle exec rake db:seed_fu




