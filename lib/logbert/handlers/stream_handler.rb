
require 'fileutils'
require 'logbert/handlers/base_handler'

module Logbert
  
  module Handlers
    
    class StreamHandler < Logbert::Handlers::BaseHandler
      attr_reader :stream
      
      def initialize(stream = $stderr)
        @stream = stream
      end
      
      def self.for_path(path)
        dirname = File.dirname(File.absolute_path(path))
        FileUtils.mkdir_p dirname unless File.exists? dirname

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

