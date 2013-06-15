
require 'logbert/naming'

describe "Logbert.split_name" do
  it "splits names using '::'" do
    Logbert.split_name("foo::bar").should == ["foo", "bar"]
  end
  
  it "does not include any empty components" do
    Logbert.split_name("foo::").should == ["foo"]
    Logbert.split_name("foo::::bar").should == ["foo", "bar"]
  end
  
  it "returns an empty array when given an empty string" do
    Logbert.split_name("").should == []
  end
end
