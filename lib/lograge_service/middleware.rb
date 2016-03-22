module LogrageService
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      request = ActionDispatch::Request.new(env)
      Thread.current[:payload] = {
          uuid: request.uuid,
          host: request.host,
          remote_ip: env['HTTP_X_REAL_IP'] || request.remote_ip,
          origin: [request.headers['HTTP_ORIGIN'], request.headers['ORIGINAL_FULLPATH']].join,
          user_agent: request.headers['HTTP_USER_AGENT']
      }

      begin
        @app.call(env)
      rescue Exception => error
        got_exception(error)
        raise error
      ensure
        Thread.current[:payload] = nil
      end
    end

    private

    def got_exception(error)
      if error.is_a?(Class) && error <= Exception
        error_class = error.name
        error_message = error.name
        backtrace = []
      else
        error_class = error.class.name
        error_message = error.message
        backtrace = error.backtrace
      end

      payload = {
          uuid: Thread.current[:payload][:uuid],
          type: 'exception',
          status: 500,
          error: error_class,
          message: error_message,
          backtrace: backtrace
      }

      Kids.publish(payload)
    end
  end
end
