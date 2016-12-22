# Custom Redis configuration
resque_url = "redis://#{Settings.redis.redis_quene_host}:#{Settings.redis.redis_quene_port}/#{Settings.redis.redis_quene_db}"

Sidekiq.configure_server do |config|
  config.redis = {
      url: resque_url ,
      namespace: 'resque:weibo'
  }
end

Sidekiq.configure_client do |config|
  config.redis = {
      url: resque_url ,
      namespace: 'resque:weibo'
  }
end