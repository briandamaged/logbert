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

      def publish(message)
        redis.lpush(@key, message.to_json)
      end

    end # class RedisQueueHandler

  end # module Handlers
end # module Logbert
