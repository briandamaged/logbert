
require 'logbert/handlers/base_handler'

module Logbert
  
  module Handlers
    
    class StreamHandler < BaseHandler
      attr_accessor :stream
      
      def initialize(stream = $stderr)
        @stream = stream
      end
      
      def emit(output)
        @stream.puts output
      end

    end
    
  end
  
end

