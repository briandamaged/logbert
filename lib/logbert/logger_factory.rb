
require 'logbert/naming'
require 'logbert/logger'
require 'logbert/levels'

module Logbert

  class LoggerFactory
    
    def initialize
      @inventory = {}
      self.root.level = Logbert::Levels[:warn]
    end
    
    def [](name_or_module)
      name = Logbert.name_for(name_or_module)
      @inventory[name] ||= begin
        l = Logger.new(self, name)
        l.extend Logbert::LevelsMixin
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


