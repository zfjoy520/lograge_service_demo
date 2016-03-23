require 'rails/railtie'

module LogrageService
  class Railtie < Rails::Railtie
    unless Rails.env.development?
      initializer "railtie.lograge_service" do |app|
        # 自定义middleware, payload附加属性添加, 异常payload生成都在里面
        app.middleware.use Middleware

        app.config.lograge.enabled = true
        app.config.lograge.formatter = Lograge::Formatters::Logstash.new
        app.config.lograge.logger = Logger.new

        app.config.lograge.custom_options = lambda do |event|
          payload = Thread.current[:payload].clone
          payload.merge!(
              type: 'request',
              source: `hostname`.chomp,
              params: event.payload[:params].as_json.except(*%w{controller action})
          )
        end

        # 覆盖掉ActiveSupport::TaggedLogging::Formatter的call方法
        app.config.log_formatter.extend Formatter

        # attach_to xxx
        LogSubscriber.attach_to :action_controller
        SqlSubscriber.attach_to :active_record
      end
    end
  end
end
