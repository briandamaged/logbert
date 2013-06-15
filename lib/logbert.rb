
require 'logbert/message'
require 'logbert/levels'

module Logbert

  NameSeparator = "::"
  
  def self.split_name(name)
    name.split(Logbert::NameSeparator).reject{|n| n.empty?}
  end
  
  def self.name_for(name_or_module)
    name_or_module.to_s
  end


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


  class LoggerFactory
    
    def initialize
      @inventory = {}
      self.root.level = Logbert::Levels::WARN
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

