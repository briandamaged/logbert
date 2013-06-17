
module Logbert
  
  class Message
    attr_reader :level, :time, :pid, :content_proc
    
    def initialize(level, time, pid, content = nil, &content_proc)
      @level        = level
      @time         = time
      @pid          = pid
      
      @content      = content
      @content_proc = content_proc
    end

    def self.create(level, content = nil, &content_proc)
      Message.new level, Time.now, Process.pid, content, &content_proc
    end

    # Returns the content.  If the content has not been created yet,
    # then call @content_proc and save the value.
    def content
      @content ||= begin
        if @content_proc
          @content_proc.call.to_s
        else
          ""
        end
      end
    end

  end
  
  
end

