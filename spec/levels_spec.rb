
require 'logbert/levels'

describe Logbert::LevelManager do
  
  context "#define_level" do
    
    let(:level_manager){ Logbert::LevelManager.new }
    
    context "name parameter" do
    
      it "allows names to be specified as Symbols" do
        level_manager.define_level(:foo, 1234)
      end
    
      it "allows names to be specified as Strings" do
        level_manager.define_level("foo", 1234)
      end
    
      it "raises an ArgumentError when the name is specified as an unsupported type" do
        expect{level_manager.define_level(Object.new, 1234)}.to raise_exception(ArgumentError)
      end
    
    end
    
    
  end
  
  
end