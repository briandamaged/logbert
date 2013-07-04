
require 'logbert/handlers/base_handler'

module Logbert
  
  module Handlers
    
    class StreamHandler < BaseHandler
      attr_accessor :stream
      
      def initialize(stream = $stderr)
        @stream = stream
      end
      
      def self.for_path(path)
        fout = File.open(path, "ab")
        StreamHandler.new fout
      end
      
      
      def emit(output)
        @stream.puts output
        @stream.flush
      end

    end
    
  end
  
end

