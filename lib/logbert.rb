
require 'logbert/formatters'
require 'logbert/handlers'
require 'logbert/logger'
require 'logbert/logger_factory'
require 'logbert/levels'
require 'logbert/message'
require 'logbert/naming'

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

