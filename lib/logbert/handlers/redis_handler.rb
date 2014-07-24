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
        output = {
          level:       level, 
          time:        msg.time, 
          pid:         msg.pid, 
          logger:      msg.logger, 
          content:     msg.content,
          exc_class:   "",
          exc_message: ""
        }
        if msg.exception
          output[:exc_class] = msg.exception.class
          output[:exc_message] = msg.exception.message
        end
        return output
      end

      def publish(message)
        redis.lpush(@key, format(message))
      end

    end # class RedisQueueHandler
  
  end # module Handlers
end # module Logbert
