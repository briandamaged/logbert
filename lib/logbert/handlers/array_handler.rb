require 'logbert/handlers/base_handler'

module Logbert
  module Handlers

    # Writes all of the log messages to an array.
    class ArrayHandler < Logbert::Handlers::BaseHandler

      attr_accessor :messages

      def initialize(messages = [])
        @messages = messages
      end

      def emit(output)
        @messages << output
      end
    end

  end
end