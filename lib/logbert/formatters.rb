
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
        level = msg.level.to_s.upcase.ljust(8)
        output = "#{level} [time='#{msg.time}' pid='#{msg.pid}' logger='#{msg.logger}'] : #{msg.content}"
        if msg.exception
          output = [output, "\n\nException information:\n", msg.exception, "\n"]
          
          backtrace = backtrace = msg.exception.backtrace
          if backtrace
            output += [backtrace.join($/), "\n\n"]
          else
            output << "(Backtrace is unavailable)\n\n"
          end
          
          output = output.join
        end
        return output
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
      ProcFormatter.new(&block)
    end

  end
end

