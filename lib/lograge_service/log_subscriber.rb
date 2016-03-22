# inspired from: https://github.com/gshaw/concise_logging
module LogrageService
  class LogSubscriber < ActiveSupport::LogSubscriber
    INTERNAL_PARAMS = %w{controller action format _method only_path}.freeze
    FORMAT = '%{cost} %{timestamp} %{request_format} %{ip} %{status} %{method} %{path}, Processing by %{controller}#%{action}'.freeze

    def redirect_to(event)
      Thread.current[:logged_location] = event.payload[:location]
    end

    def process_action(event)
      payload = event.payload
      param_method = payload[:params]['_method']
      method = param_method ? param_method.upcase : payload[:method]

      status, exception_details = compute_status(payload)
      path = payload[:path].to_s.gsub(/\?.*/, '')
      controller, action = payload[:controller], payload[:action]
      internal_params = INTERNAL_PARAMS | %w{path}
      params = payload[:params].except(*internal_params)

      location = Thread.current[:logged_location]
      Thread.current[:logged_location] = nil

      message = format(FORMAT,
                       cost: format_cost(event),
                       timestamp: format_timestamp(event),
                       request_format: format_request_format(event),
                       ip: format_ip,
                       status: format_status(status),
                       method: format_method(format('%-6s', method)),
                       path: path,
                       controller: controller,
                       action: action)

      message << ", Parameters: #{params}" if params.present?
      message << ", RedirectTo: #{location}" if location.present?
      message << "\n#{color(exception_details, RED)}" if exception_details.present?

      logger.info message
    end

    private

    def compute_status(payload)
      details = nil
      status = payload[:status]
      if status.nil? && payload[:exception].present?
        exception_class_name = payload[:exception].first
        status = ActionDispatch::ExceptionWrapper.status_code_for_exception(exception_class_name)

        if payload[:exception].respond_to?(:uniq)
          details = payload[:exception].uniq.join(' ')
        end
      end
      [status, details]
    end

    def format_method(method)
      if method.strip == 'GET'
        method
      else
        color(method, CYAN)
      end
    end

    def format_status(status)
      status = status.to_i
      if status >= 400
        color(status, RED)
      elsif status >= 300
        color(status, YELLOW)
      else
        color(status, GREEN)
      end
    end

    def format_cost(event)
      total_runtime = event.end.to_f - event.time.to_f
      db_runtime = event.payload[:db_runtime].to_f * 0.001
      cost = format('[%0.3f|%0.3f]', total_runtime, db_runtime)
      total_runtime.to_f > 1 ? color(cost, RED) : cost
    end

    def format_timestamp(event)
      format('[%s]', event.end.to_s(:db))
    end

    def format_request_format(event)
      request_format = event.payload[:format].to_s.upcase
      msg = %w{JSON XML}.include?(request_format) ? '[API]' : "[#{request_format}]"
      msg = format('%-6s', msg)
      %w{JSON XML}.include?(request_format) ? color(msg, RED) : color(msg, CYAN)
    end

    def format_ip
      format('%-15s', Thread.current[:payload][:remote_ip] || '0.0.0.0')
    end
  end
end
