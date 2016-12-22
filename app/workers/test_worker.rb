

class TestWorker
  include Sidekiq::Worker

  def perform
    Weibo::Logger.info("Action" => "测试线程安全")
  end
end