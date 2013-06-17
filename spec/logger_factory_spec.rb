
require 'logbert/logger_factory'

describe Logbert::LoggerFactory do
  
  let(:factory){Logbert::LoggerFactory.new}
  
  context "#[]" do
    it "maps each name to a distinct Logger instance" do
      factory["foo/bar"].should === factory["foo/bar"]
      factory["foo/bar"].should_not === factory["foo/bar/quux"]
    end
    
    
    it "allows Loggers to be obtain by module or name" do
      factory[Logbert::LoggerFactory].should === factory["Logbert/LoggerFactory"]
      factory[Logbert::LoggerFactory].should_not === factory["Logbert"]
    end
    
    
    it "ensures that the root logger and the unnamed logger are the same" do
      factory[''].should === factory.root
    end
    
  end
  
  
  context "#parent_for" do
    
    it "returns the parent for the specified logger" do
      factory.parent_for(factory["foo/bar"]).should === factory["foo"]
    end
    
    it "returns the root Logger when given a Logger at the bottom of the hierarchy" do
      factory.parent_for(factory["foo"]).should === factory.root
    end
    
    it "returns nil when given the root Logger" do
      factory.parent_for(factory.root).should be_nil
    end
    
  end
  
  
  
end
