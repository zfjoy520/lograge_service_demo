module LogrageService
  extend ActiveSupport::Autoload

  autoload :Middleware
  autoload :Kids
  autoload :SqlSubscriber
  autoload :LogSubscriber
  autoload :Logger
  autoload :Formatter
end

require_relative 'lograge_service/railtie' if defined?(Rails)
