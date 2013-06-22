
require 'logbert/levels'

describe Logbert::LevelManager do
  
  let(:level_manager){ Logbert::LevelManager.new }
  
  context "#define_level" do

    it "allows names to be specified as Symbols" do
      level_manager.define_level(:foo, 1234).should be_a(Logbert::Level)
    end
  
    it "allows names to be specified as Strings" do
      level_manager.define_level("foo", 1234).should be_a(Logbert::Level)
    end
  
    it "raises an ArgumentError when the name cannot be converted to a Symbol" do
      expect{level_manager.define_level(Object.new, 1234)}.to raise_exception(ArgumentError)
    end
    
    it "raises a KeyError when a Level with the specified name is already defined" do
      level_manager.define_level(:foo, 123)
      expect{level_manager.define_level(:foo, 321)}.to raise_exception(KeyError)
    end
    
    
    
    it "allows Level values to be specified as Integers" do
      level_manager.define_level(:foo, 111).should be_a(Logbert::Level)
      level_manager.define_level(:bar, 2**100).should be_a(Logbert::Level)
    end
    
    it "raises an ArgumentError when the Level value is not an Integer" do
      expect{level_manager.define_level(:foo, :bar)}.to raise_exception(ArgumentError)
    end
    
    
    it "raises a KeyError when a Level with the specified value is already defined" do
      level_manager.define_level(:foo, 123)
      expect{level_manager.define_level(:bar, 123)}.to raise_exception(KeyError)
    end
    
    
  end
  
  
end