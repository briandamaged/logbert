require 'logbert/handlers/base_handler'
require 'redis'

module Logbert
  module Handlers

    class RedisQueueHandler < Logbert::Handlers::BaseHandler

      attr_accessor :redis, :key

      def initialize(redis_connection, key, options = {})
        @redis = redis_connection
        @key   = key
      end

      def format(msg)
        level = msg.level.to_s.upcase.ljust(8)
        serialized_msg = {
          level:        level,
          time:         msg.time,
          pid:          msg.pid,
          logger:       msg.logger,
          options:      msg.options
          content:      msg.content,
          content_proc: msg.content_proc
          exc_info:     nil
        }
        serialized_msg[:exc_info] = msg.exception if msg.exception
        return serialized_msg
      end

      def publish(message)
        redis.lpush(@key, format(message))
      end

    end # class RedisQueueHandler

  end # module Handlers
end # module Logbert