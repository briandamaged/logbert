
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
    
    def log(level, *args, &block)
      content, options = self.prepare_message_args(*args, &block)
      
      exception = options[:exc_info]
      if exception
        # If the user passed in an exception, then use that one.
        # Otherwise, check the magic $! variable to see if an
        # exception is currently being handled.
        exception = $! unless exception.is_a? Exception
      end

      message = Logbert::Message.create(self, @level_manager[level], exception, options, content, &block)
      handle_message(message)
    end
    
    
    def to_s
      @name
    end
    
    protected
    
    
    # This method will be unnecessary once we upgrade to Ruby 2.x
    def prepare_message_args(*args, &block)
      if args.size == 0
        return [nil, {}]
      elsif args.size == 1
        if block_given?
          return [nil, args[0]]
        else
          return [args[0], {}]
        end
      elsif args.size == 2
        return [args[0], args[1]]
      else
        raise ArgumentError, "wrong number of arguments (#{args.size} for 0..2)"
      end
    end

    def handle_message(message)
      if message.level.value >= self.level.value
        @handlers.each{|h| h.publish message}
      end

      p = self.parent
      p.handle_message(message) if p
    end

  end

end

