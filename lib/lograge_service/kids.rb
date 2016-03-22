# https://github.com/zhihu/kids
# kids订阅服务, 需要采用异步处理, 否则会阻塞
module LogrageService
  class Kids
    include Concurrent::Async

    CONFIG = ::Settings::Kids

    @@adapter = Redis.new(CONFIG.slice(:host, :port))

    attr_reader :message

    def self.publish(message)
      new(message).async.publish
    end

    def publish
      adapter.publish(CONFIG.channel, message)
    end

    private

    def initialize(message)
      @message = message
    end

    def adapter
      self.class.class_variable_get('@@adapter')
    end
  end
end
