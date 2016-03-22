module LogrageService
  class SqlSubscriber < ActiveSupport::LogSubscriber
    IGNORE_PAYLOAD_NAMES = ['SCHEMA', 'EXPLAIN', 'ActiveRecord::SchemaMigration Load'].freeze

    def sql(event)
      return if IGNORE_PAYLOAD_NAMES.include?(event.payload[:name])

      payload = {
          uuid: Thread.current[:payload][:uuid],
          type: 'sql',
          name: event.payload[:name],
          duration: ((event.end - event.time) * 1_000).round,
          message: event.payload[:sql]
      }

      Kids.publish(payload)
    end
  end
end
