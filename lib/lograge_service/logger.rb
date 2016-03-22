module LogrageService
  class Logger
    def self.publish(message)
      new.publish(message)
    end

    def publish(message)
      Kids.publish(message)
    end

    alias_method :info, :publish
    alias_method :warn, :publish
    alias_method :error, :publish
    alias_method :fatal, :publish
    alias_method :unknown, :publish
  end
end
