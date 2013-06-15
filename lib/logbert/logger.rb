
module Logbert
  
  class Logger
    
    attr_reader :factory, :name
    
    def initialize(factory, name)
      @factory = factory
      @name = name
    end
    
    def level_inherited?
      !!@level
    end
    
    def level
      @level || parent.level
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
    
    def log(level, msg)
      if level >= @level
        puts "[#{Time.now}]: #{msg}"
      end
    end

  end


end