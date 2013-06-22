
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
    
    def inspect
      "Level(#{@name.inspect}, #{@value})"
    end
  end

  # This class doubles as a mixin.  Bazinga!
  class LevelManager < Module
    
    def initialize
      @level_to_aliases = {}

      @quick_lookup   = {}
      
      Logbert::DefaultLevels.each{|name, value| self.define_level(name, value)}
      self.alias_level :warn, :warning
    end
    

    def levels
      @level_to_aliases.keys
    end

    def aliases_for(level)
      level = self.level_for(level)
      @level_to_aliases.fetch(level)
    end
    
    def define_level(name, value)
      raise ArgumentError, "The Level's name must implement #to_sym" unless name.respond_to? :to_sym
      raise ArgumentError, "The Level's value must be an Integer" unless value.is_a? Integer
      
      name = name.to_sym
      
      raise KeyError, "A Level with that name is already defined:  #{name}"  if @quick_lookup.has_key? name
      raise KeyError, "A Level with that value is already defined: #{value}" if @quick_lookup.has_key? value
      
      level = Level.new(name, value)

      @quick_lookup[name] = @quick_lookup[value] = @quick_lookup[level] = level
      @level_to_aliases[level] = [name]
      
      self.create_logging_method(name)
      self.create_predicate_method(name, value)
      
      return level
    end
    
    
    def alias_level(alias_name, level)
      raise ArgumentError, "The Level alias must implement #to_sym: #{alias_name}" unless alias_name.respond_to? :to_sym
      
      alias_name = alias_name.to_sym
      
      preexisting_level = @quick_lookup[alias_name]
      if preexisting_level
        raise KeyError, "The alias is already taken: #{alias_name} -> #{preexisting_level}"
      end
      
      level = self.level_for(level, false)

      @level_to_aliases[level] << alias_name
      @quick_lookup[alias_name] = level
      
      alias_method alias_name, level.name
      alias_method "#{alias_name}?", "#{level.name}?"
      
      return level
    end


    def level_for(x, allow_virtual_levels = true)
      @quick_lookup[x] or begin
        if x.is_a? Integer
          return Logbert::Level.new("LEVEL_#{x}".to_sym, x) if allow_virtual_levels
        elsif x.is_a? String
          level = @name_to_level[x.to_sym]
          return level if level
        end

        raise KeyError, "No Level could be found for input: #{x}"
      end
    end
    
    alias :[] :level_for

    protected
    
    def create_logging_method(level_name)
      define_method level_name do |*args, &block|
        self.log(level_name, *args, &block)
      end
    end
    
    def create_predicate_method(level_name, level_value)
      define_method "#{level_name}?" do
         self.level.value <= level_value
      end
    end


  end


end
