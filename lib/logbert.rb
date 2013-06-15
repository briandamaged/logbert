
module Logbert

  OFF   = 0
  DEBUG = 10
  INFO  = 20
  WARN  = 30
  ERROR = 40
  FATAL = 50


  NameSeparator = "::"
  
  def self.split_name(name)
    name.split(Logbert::NameSeparator).reject{|n| n.empty?}
  end
  
  def self.name_for(name_or_module)
    name_or_module.to_s
  end



  Message = Struct.new :level, :content, :time

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
      @level or parent.level
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
      self.log(Logbert::DEBUG, msg)
    end

    def info(msg)
      self.log(Logbert::INFO, msg)
    end
    
    def warn(msg)
      self.log(Logbert::WARN, msg)
    end
    
    def error(msg)
      self.log(Logbert::ERROR, msg)
    end
    
    def fatal(msg)
      self.log(Logbert::FATAL, msg)
    end
    

    def log(level, msg)
      if level >= @level
        puts "[#{Time.now}]: #{msg}"
      end
    end

  end


  class LoggerFactory
    
    def initialize
      @inventory = {}
      self.root.level = Logbert::WARN
    end
    
    def [](name_or_module)
      name = Logbert.name_for(name_or_module)
      @inventory[name] ||= Logger.new(self, name)
    end
    
    def root
      @root ||= self['']
    end
    
    def parent_for(logger)
      n = logger.name
      unless n.empty?
        components = Logbert.split_name(n)
        components.pop
        parent_name = components.join(Logbert::NameSeparator)
        return self[parent_name]
      end
    end

  end


  def self.factory
    @factory ||= LoggerFactory.new
  end

  def self.[](name)
    self.factory[name]
  end
  
  def self.root
    self.factory.root
  end

end

