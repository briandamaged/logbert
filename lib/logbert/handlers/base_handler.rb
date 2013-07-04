
require 'logbert/formatters'

module Logbert
  module Handlers
    
        
    class BaseHandler
      
      def formatter
        @formatter ||= Logbert::Formatters::SimpleFormatter.new
      end
      
      def formatter=(value)
        @formatter = value
      end

      def publish(message)
        emit self.formatter.format(message)
      end
      
      def emit(output)
        raise NotImplementedError
      end

    end
    

  end
end