
module Logbert

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
