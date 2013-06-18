
module Logbert

  DefaultLevels = {
    debug:    100,
    info:     200,
    warning:  300,
    error:    400,
    fatal:    500,
  }


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

      @quick_lookup   = {}
      
      Logbert::DefaultLevels.each{|name, value| self.define_level(name, value)}
    end
    
    def names
      @name_to_level.keys
    end
    
    def values
      @value_to_level.keys
    end
    
    def levels
      @name_to_level.values
    end    

    
    def define_level(name, value)
      unless name.instance_of?(Symbol) or name.instance_of?(String)
        raise ArgumentError, "The Level's name must be a Symbol or a String"
      end
      raise ArgumentError, "The Level's value must be an Integer" unless value.is_a? Integer
      
      # TODO: Verify that the name/value are not already taken
      raise KeyError, "A Level with that name is already defined: #{name}" if @name_to_level.has_key? name
      raise KeyError, "A Level with that value is already defined: #{value}" if @value_to_level.has_key? value
      
      level = Level.new(name, value)

      @name_to_level[name]   = level
      @value_to_level[value] = level
      @quick_lookup[name] = @quick_lookup[value] = @quick_lookup[level] = level
      
      self.create_logging_method(name)
      self.create_predicate_method(name, value)
    end


    def [](x)
      @quick_lookup[x] or begin
        if x.is_a? Integer
          # Return either the pre-defined level, or produce a virtual level.
          level = @value_to_level[x] || Logbert::Level.new("LEVEL_#{x}".to_sym, x)
          return level
        elsif x.is_a? String
          level = @name_to_level[x.to_sym]
          return level if level
        end
        
        raise KeyError, "No Level could be found for input: #{x}"
      end
    end


    protected
    
    def create_logging_method(level_name)
      define_method level_name do |content = nil, &block|
        self.log(level_name, content, &block)
      end
    end
    
    def create_predicate_method(level_name, level_value)
      define_method "#{level_name}?" do
         self.level.value <= level_value
      end
    end


  end


end
