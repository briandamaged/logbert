
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
  class LevelsManager < Module
    
    def initialize
      @name_to_level  = {}
      @value_to_level = {}
    end
    
    def define_level(name, value)
      raise ArgumentError, "The Level's name must be a Symbol" unless name.is_a? Symbol
      raise ArgumentError, "The Level's value must be an Integer" unless value.is_a? Integer
      
      # TODO: Verify that the name/value are not already taken
      raise KeyError, "A Level with that name is already defined: #{name}" if @name_to_level.has_key? name
      raise KeyError, "A Level with that value is already defined: #{value}" if @value_to_level.has_key? value
      
      level = Level.new(name, value)
      @name_to_level[name]   = level
      @value_to_level[value] = level
    end
    
    def levels
      @name_to_level.values
    end
    
    
    def level_for(x)
      if x.respond_to? :to_sym
        self.level_for_name(x)
      else
        self.level_for_value(x)
      end
    end

    def level_for_name(name)
      @name_to_level.fetch(name.to_sym)
    end
    
    def level_for_value(value)
      value = Integer(value)
      @value_to_level[value] or Logbert::Level.new("LEVEL_#{value}", value)
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
