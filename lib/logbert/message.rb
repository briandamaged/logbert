
module Logbert
  
  Message = Struct.new :level, :content, :time, :pid do
    
    def create(level, content)
      Message.new level, content, Time.now, Process.pid
    end
    
  end
  
end

