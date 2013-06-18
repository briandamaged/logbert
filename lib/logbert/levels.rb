
module Logbert

  class Level
    attr_reader :name, :value
    
    def initialize(name, value)
      @name  = name
      @value = value
    end
    
    def to_s
      @name.to_s
    end
  end

  # This class doubles as a mixin.  Bazinga!
  class LevelManager < Module
    
    def initialize
      @name_to_level  = {}
      @value_to_level = {}
    end
    
    def define_level(name, value)
      raise ArgumentError, "The Level's name must be a Symbol" unless name.instance_of? Symbol
      raise ArgumentError, "The Level's value must be an Integer" unless value.is_a? Integer
      
      # TODO: Verify that the name/value are not already taken
      raise KeyError, "A Level with that name is already defined: #{name}" if @name_to_level.has_key? name
      raise KeyError, "A Level with that value is already defined: #{value}" if @value_to_level.has_key? value
      
      level = Level.new(name, value)
      @name_to_level[name]   = level
      @value_to_level[value] = level
      
      self.create_logging_method(level)
    end
    
    def levels
      @name_to_level.values
    end
    
    
    def level_for(x)
      if x.is_a? Logbert::Level
        x
      elsif x.is_a? Numeric
        self.level_for_value(x)
      else
        self.level_for_name(x)
      end
    end

    def level_for_name(name)
      @name_to_level.fetch(name.to_sym)
    end
    
    def level_for_value(value)
      value = Integer(value)
      @value_to_level[value] or Logbert::Level.new("LEVEL_#{value}".to_sym, value)
    end


    protected
    
    def create_logging_method(level)
      define_method level.name do |content = nil, &block|
        self.log(level, content, &block)
      end
    end


  end
  
  

  Levels = {
    off:    0,
    debug: 10,
    info:  20,
    warn:  30,
    error: 40,
    fatal: 50,
    all:   100
  }

  
  
  module LevelsMixin
    
    Logbert::Levels.each do |level_name, level_value|
      define_method level_name do |content = nil, &block|
        self.log(level_value, content, &block)
      end
    end
    
  end

end
