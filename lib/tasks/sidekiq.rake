namespace :sidekiq do
  desc "GITLAB | Stop sidekiq"
  task :stop do
    exec "kill -s 9 $(pgrep side)"
  end

  desc "GITLAB | Start sidekiq"
  task :start do
    exec "bundle exec sidekiq -C config/sidekiq.yml"
  end
end
