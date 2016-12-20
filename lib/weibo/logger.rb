module Weibo
  class Logger < ::Logger
    def self.file_name
      time = Time.new
      time.strftime("%Y-%m-%d-application.log")
    end
    def self.error(message)
      build.error(message)
      Rails.logger.error(message)
    end

    def self.info(message)
      build.info(message)
      Rails.logger.info(message)
    end

    def self.read_latest
      path = Rails.root.join("log", file_name)
      self.build unless File.exist?(path)
      logs = `tail -n 2000 #{path}`.split("\n")
    end

    def self.read_latest_for filename
      path = Rails.root.join("log", filename)
      logs = `tail -n 2000 #{path}`.split("\n")
    end

    def self.build
      logger =  new(Rails.root.join("log", file_name))
      log_level = DEBUG#INFO\WARN\ERROR\FATAL\UNKNOWN
      logger.level = log_level
      logger
    end

    def format_message(severity, timestamp, progname, msg)
      "[#{severity}] [#{timestamp.strftime("%Y-%m-%d %H:%M:%S.%L")}]: #{msg}\n"
    end
  end
end
