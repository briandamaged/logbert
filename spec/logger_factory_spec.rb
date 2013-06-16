
require 'logbert/logger_factory'

describe Logbert::LoggerFactory do
  
  let(:factory){Logbert::LoggerFactory.new}
  
  context :"[]" do
    it "maps each name to a distinct Logger instance" do
      factory["foo/bar"].should === factory["foo/bar"]
      factory["foo/bar"].should_not === factory["foo/bar/quux"]
    end
    
    
    it "allows Loggers to be obtain by module or name" do
      factory[Logbert::LoggerFactory].should === factory["Logbert/LoggerFactory"]
      factory[Logbert::LoggerFactory].should_not === factory["Logbert"]
    end
    
  end
  
end
