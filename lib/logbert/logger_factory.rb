
require 'logbert/naming'
require 'logbert/logger'
require 'logbert/levels'

module Logbert

  class LoggerFactory
    
    attr_reader :level_manager
    
    def initialize(level_manager = LevelManager.new)
      @inventory = {}
      @level_manager  = level_manager
      self.root.level = @level_manager[:warn]
    end
    
    def [](name_or_module)
      name = Logbert.name_for(name_or_module)
      @inventory[name] ||= begin
        l = Logger.new(self, @level_manager, name)
        l.extend @level_manager
      end
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

end


