
module Logbert
  
  NameSeparator = "/"

  def self.split_name(name)
    name.split(Logbert::NameSeparator).reject{|n| n.empty?}
  end

  def self.name_for(n)
    if n.is_a? Module
      n.name.gsub("::", Logbert::NameSeparator)
    else
      Logbert.split_name(n.to_s).join(Logbert::NameSeparator)
    end
  end

end


