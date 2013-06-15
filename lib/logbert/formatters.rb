
require 'logbert/message'

module Logbert
  
  module Formatters
    
    class Simple
      def format(msg)
        "[#{msg.time}]: #{msg.content}"
      end
    end

  end
end

