require 'redis'
require 'logbert/message'
require 'logbert/handlers'

module Logbert
  module Consumers

    class RedisConsumer

      attr_accessor :redis, :key, :handlers

      def initialize(redis_connection, key, options = {})
        @redis    = redis_connection
        @key      = key
        @handlers = options.fetch(:handlers, [])
      end

      def work
        # Blocking loop to read serialized messages of the redis queue
        loop do
          msg = redis.brpop(key) # blocking list pop primitive
          @handlers.each do |h|
            m = Message.from_json(msg)
            h.handle_message(m)
          end
        end
      end

    end # class RedisConsumer

  end # module Consumers
end # module Logbert
