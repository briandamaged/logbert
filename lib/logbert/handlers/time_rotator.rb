
require 'fileutils'
require 'logbert/handlers/base_handler'

module Logbert
  
  module Handlers
    
    class LocaltimeFormatter
      
      attr_accessor :format

      def initialize(format = "%Y-%m-%d-%H%M")
        @format = format
      end

      def format(time)
        time.strftime(@format)
      end
    end

    
    class TimeRotator < Logbert::Handlers::BaseHandler
      
      
      attr_reader :path, :stream, :timestamp_formatter
      attr_reader :interval, :expiration_time
      
      def initialize(path, options = {})
        @path                = path
        @timestamp_formatter = options[:timestamp_formatter] || LocaltimeFormatter.new
        @interval            = options.fetch(:iterval, 24 * 60 * 60)
        
        rotate_log!
      end
      
      
      def rotation_needed?
        Time.now > @expiration_time
      end
      
      
      def rotate_log!
        if @stream and not @stream.closed?
          @stream.close
        end
        
        if File.exists? @path
          FileUtils.mv @path, archive_destination
        end
        
        @stream = File.open(@path, "ab")

        @expiration_time = Time.now + @interval
      end

      
      
      def emit(output)
        rotate_log! if rotation_needed?
        @stream.puts output
        @stream.flush
      end
      
      
      private
      
      
      def archive_destination
        timestamp = @timestamp_formatter.format(File.ctime(@path))
        dest = "#{path}.#{timestamp}"
        return dest
      end
      
    end
    
    
  end
  
end
