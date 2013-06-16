
require 'logbert/message'

module Logbert
  
  module Formatters
    
    class Formatter
      def format(msg)
        raise NotImplementedError
      end
    end
    
    class SimpleFormatter < Formatter
      def format(msg)
        "[#{msg.time} #{msg.pid}]: #{msg.content}"
      end
    end
    
    
    class ProcFormatter < Formatter
      attr_accessor :proc

      def initialize(&block)
        raise ArgumentError, "ProcFormatter must be initialized with a block" unless block_given?
        @proc = block
      end
      
      def format(msg)
        @proc.call msg
      end
    end
    
    def self.fmt(&block)
      ProcFormatter(&block)
    end

  end
end

