
module Logbert
  
  NameSeparator = "::"

  def self.split_name(name)
    name.split(Logbert::NameSeparator).reject{|n| n.empty?}
  end

  def self.name_for(name_or_module)
    name_or_module.to_s
  end

end


