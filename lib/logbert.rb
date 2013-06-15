
require 'logbert/levels'
require 'logbert/logger_factory'

module Logbert

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

