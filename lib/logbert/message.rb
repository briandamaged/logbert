
module Logbert
  
  class Message
    attr_reader :logger, :level, :time, :pid, :options, :content_proc
    
    def initialize(logger, level, time, pid, options, content = nil, &content_proc)
      @logger       = logger
      @level        = level
      @time         = time
      @pid          = pid
      @options      = options
      
      @content      = content
      @content_proc = content_proc
    end

    def self.create(logger, level, options, content = nil, &content_proc)
      Message.new logger, level, Time.now, Process.pid, options, content, &content_proc
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

