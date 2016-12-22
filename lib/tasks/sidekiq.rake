namespace :sidekiq do
  desc "GITLAB | Stop sidekiq"
  task :stop do
    run "bundle exec sidekiqctl stop #{pidfile}"
  end

  desc "GITLAB | Start sidekiq"
  task :start do
    run "nohup bundle exec sidekiq -e #{Rails.env} -P #{pidfile} >> /dev/null 2>&1 &"
  end
  
  desc "GITLAB | Start sidekiq with launchd on Mac OS X"
  task :launchd do
    run "nohup bundle exec sidekiq -e #{Rails.env} -P #{pidfile} >> #{Rails.root.join("log", "sidekiq.log")} 2>&1 &"
  end
  
  def pidfile
    Rails.root.join("tmp", "pids", "sidekiq.pid")
  end
end
