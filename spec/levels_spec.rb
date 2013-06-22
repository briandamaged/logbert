
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
  
  
  
  context "#alias_level" do

    context "when the Level :foo is already defined" do
      
      before do
        level_manager.define_level(:foo, 123)
      end
      
      it "allows the alias to be specified as a String" do
        level_manager.alias_level("bar", :foo).should be_a(Logbert::Level)
        level_manager[:bar].should === level_manager[:foo]
      end
      
      it "allows the alias to be specified as a Symbol" do
        level_manager.alias_level(:bar, :foo).should be_a(Logbert::Level)
        level_manager[:bar].should === level_manager[:foo]
      end
      
      it "raises an ArgumentError when the alias cannot be converted to a Symbol" do
        expect{level_manager.alias_level(123, :foo)}.to raise_exception(ArgumentError)
      end
      
      it "allows the level to be identified by name" do
        level_manager.alias_level(:bar, :foo)
        level_manager[:bar].should === level_manager[:foo]
      end
      
      
      it "allows the level to be identified by value" do
        level_manager.alias_level(:bar, 123)
        level_manager[:bar].should === level_manager[:foo]
      end
      
      it "allows the Level to be aliased directly" do
        level = level_manager[:foo]
        level_manager.alias_level(:bar, level)
        
        level_manager[:bar].should === level_manager[:foo]
      end
      
      
      it "raises a KeyError when an existing Level is already defined by the desired alias" do
        expect{level_manager.alias_level(:foo, :foo)}.to raise_exception(KeyError)
        
        level_manager.alias_level(:bar, :foo)
        expect{level_manager.alias_level(:bar, :foo)}.to raise_exception(KeyError)
        expect{level_manager.alias_level(:foo, :bar)}.to raise_exception(KeyError)
      end
      
      it "creates a logging shortcut method with the same name as the alias" do
        level_manager.instance_methods.should_not include(:bar)
        
        level_manager.alias_level(:bar, :foo)
        level_manager.instance_methods.should include(:bar)
      end
      
      
      it "creates a predicate method with the same name as the alias" do
        level_manager.instance_methods.should_not include(:bar?)
        
        level_manager.alias_level(:bar, :foo)
        level_manager.instance_methods.should include(:bar?)
      end
      
    end

    

    it "raises a KeyError when the Level cannot be identified" do
      expect{level_manager.alias_level(:bar, :what)}.to raise_exception(KeyError)
    end

  end
  
  
  
  
end