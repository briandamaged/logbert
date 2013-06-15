
require 'logbert/message'

module Logbert
  
  module Formatters
    
    class Formatter
      def format(msg)
        raise NotImplementedError
      end
    end
    
    class SimpleFormatter
      def format(msg)
        "[#{msg.time} #{msg.pid}]: #{msg.content}"
      end
    end
    
    
    class ProcFormatter
      attr_accessor :proc

      def initialize(&block)
        @proc = block
      end
      
      def format(msg)
        @proc.call msg
      end
    end

  end
end

