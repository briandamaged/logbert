
require 'logbert/naming'

describe "Logbert.split_name" do
  it "splits names using '/'" do
    Logbert.split_name("foo/bar").should == ["foo", "bar"]
  end
  
  it "does not include any empty components" do
    Logbert.split_name("foo/").should == ["foo"]
    Logbert.split_name("foo//bar").should == ["foo", "bar"]
  end
  
  it "returns an empty array when given an empty string" do
    Logbert.split_name("").should == []
  end
end



module Foo
  module Bar
    class Quux
    end
  end
end


describe "Logbert.name_for" do
  
  it "assumes Modules map to a hierarchical structure" do
    Logbert.name_for(Foo::Bar::Quux).should == "Foo/Bar/Quux"
  end

  it "removes extra '/' character from Strings" do
    Logbert.name_for("///fwu//ha/ha///").should == "fwu/ha/ha"
  end
  
  it "converts symbols to strings" do
    Logbert.name_for(:foo).should == "foo"
  end

  
end

