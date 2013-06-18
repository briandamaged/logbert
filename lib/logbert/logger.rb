
require 'logbert/message'
require 'logbert/handlers'

module Logbert
  
  class Logger
    
    attr_reader :factory, :level_manager, :name, :handlers
    
    def initialize(factory, level_manager, name)
      @factory       = factory
      @level_manager = level_manager

      @name     = name.dup.freeze
      @handlers = []
    end
    
    def level_inherited?
      !!@level
    end
    
    def level
      @level || self.parent.level
    end
    
    def level=(x)
      @level = @level_manager[x]
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
    
    def log(level, content = nil, &block)
      message = Logbert::Message.create(self, @level_manager[level], content, &block)
      handle_message(message)
    end
    
    
    def to_s
      @name
    end
    
    protected

    def handle_message(message)
      if message.level.value >= self.level.value
        @handlers.each{|h| h.publish message}
      end

      p = self.parent
      p.handle_message(message) if p
    end

  end

end

