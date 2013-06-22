
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
    
    it "creates a logging shortcut method with the same name as the Logger" do
      level_manager.instance_methods.should_not include(:foo)
      
      level_manager.define_level(:foo, 123)
      level_manager.instance_methods.should include(:foo)
    end
    
    
    it "creates a logging predicate method with the same name as the Logger" do
      level_manager.instance_methods.should_not include(:foo?)
      
      level_manager.define_level(:foo, 123)
      level_manager.instance_methods.should include(:foo?)
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
  
  
  context "#levels" do
    
    # TODO: First, refactor constructor to produce an empty LevelManager instance
    it "returns the list of levels supported by the LevelManager instance"
    
  end

  
  
  context "#aliases_for" do


    it "returns the list of names that identify the specified level" do
      level = level_manager.define_level(:foo, 12345)
      
      [level, :foo, 12345].each do |foo|
        level_manager.aliases_for(foo).should == [:foo]
      end
      
      level_manager.alias_level(:bar, :foo)
      level_manager.alias_level(:quux, :foo)
      
      [level, :foo, 12345].each do |foo|
        aliases = level_manager.aliases_for(foo)
        
        aliases.size.should == 3
        aliases.should include(:foo, :bar, :quux)
      end
    end

    
    it "raises a KeyError when the specified Level cannot be identified" do
      expect{ level_manager.aliases_for(:foo) }.to raise_exception(KeyError)
      expect{ level_manager.aliases_for(1535) }.to raise_exception(KeyError)
      
      # This Level is not managed by the LevelManager, so it will fail the lookup
      l = Logbert::Level.new(:debug, "12345")
      expect{ level_manager.aliases_for(l) }.to raise_exception(KeyError)
    end
    
  end
  
  
  
  
  context "#level_for" do
  
    context "when given something that can be converted to a Symbol" do
      
      it "returns the Level that has the specified name" do
        level = level_manager.define_level(:foo, 12345)
        level_manager.level_for(:foo).should === level
        level_manager.level_for("foo").should === level
      end
      
      it "raises a KeyError when there is no Level with the specified name" do
        expect{ level_manager.level_for(:bar) }.to raise_exception(KeyError)
        expect{ level_manager.level_for("bar") }.to raise_exception(KeyError)
      end
      
    end
      
    context "when given an Integer" do
      
      it "returns the Level that has the specified value" do
        level = level_manager.define_level(:foo, 12345)
        level_manager.level_for(12345).should === level
      end
      
      context "when there is no Level with the specified value" do
        
        it "returns a virtual Level when allow_virtual_levels = true" do
          level = level_manager.level_for(12345, true)
          level.should be_a(Logbert::Level)
          level.value.should == 12345
        end
        
        it "raises a KeyError when allow_virtual_levels = false" do
          expect{ level_manager.level_for(12345, false) }.to raise_exception(KeyError)
        end
        
      end
      
    end
    
    
    context "when given a Level" do
      
      it "returns the Level if it is managed by the LevelManager" do
        level = level_manager.define_level(:foo, 12345)
        level_manager.level_for(level).should === level
      end
      
      it "raises a KeyError if the Level is not managed by the LevelManager" do
        level_manager.define_level(:foo, 12345)
        
        # This level instance is NOT managed by the LevelManager
        level = Logbert::Level.new(:foo, 12345)
        expect{ level_manager.level_for(level) }.to raise_exception(KeyError)
      end
      
    end
    
    
  end


end