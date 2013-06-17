
require 'logbert/message'
require 'logbert/handlers'

module Logbert
  
  class Logger
    
    attr_reader :factory, :name, :handlers
    
    def initialize(factory, name)
      @factory = factory
      @name = name
      @handlers = []
    end
    
    def level_inherited?
      !!@level
    end
    
    def level
      @level || self.parent.level
    end
    
    def level=(value)
      @level = value
    end


    def parent
      unless @parent_defined
        @parent = @factory.parent_for(self)
        @parent_defined = true
      end
      return @parent
    end

    def root
      self.factory.root
    end
    

    def debug(msg)
      self.log(Logbert::Levels::DEBUG, msg)
    end

    def info(msg)
      self.log(Logbert::Levels::INFO, msg)
    end
    
    def warn(msg)
      self.log(Logbert::Levels::WARN, msg)
    end
    
    def error(msg)
      self.log(Logbert::Levels::ERROR, msg)
    end
    
    def fatal(msg)
      self.log(Logbert::Levels::FATAL, msg)
    end
    
    def log(level, content)
      message = Logbert::Message.create level, content
      handle_message(message)
    end
    
    protected
    
    def handle_message(message)
      if message.level >= self.level
        @handlers.each{|h| h.publish message}
      end

      p = self.parent
      p.handle_message(message) if p
    end

  end

end

