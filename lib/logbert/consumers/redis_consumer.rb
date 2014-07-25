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
            # Deserialize the message
            exception = msg[:exc_info]
            if exception
              # If the user passed in an exception, then use that one.
              # Otherwise, check the magic $! variable to see if an
              # exception is currently being handled.
              exception = $! unless exception.is_a? Exception
            end
            message = Logbert::Message.create(self, msg[:level], exception, options, msg[:content], msg[:content_proc])
            h.handle_message(message)
          end
        end
      end

    end # class RedisConsumer

  end # module Consumers
end # module Logbert
