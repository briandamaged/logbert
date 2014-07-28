
module Logbert
  class Message
    attr_reader :logger, :level, :time, :pid, :exception, :options, :content_proc

    def initialize(logger, level, time, pid, exception, options, content = nil, &content_proc)
      @logger       = logger
      @level        = level
      @time         = time
      @pid          = pid
      @exception    = exception
      @options      = options

      @content      = content
      @content_proc = content_proc
    end

    def self.create(logger, level, exception, options, content = nil, &content_proc)
      Message.new logger, level, Time.now, Process.pid, Message.convert_exception(exception), options, content, &content_proc
    end

    def self.from_json(json_msg)
      l = Level.new(json_msg[:level_name], json_msg[:level_value])
      logger = nil
      # note: the exception key contains a hash-level representation of an exception
      Message.create(logger, l, json_msg[:exception], json_msg[:options], json_msg[:content], json_msg[:content_proc])
    end

    def to_json
      return {
        logger:       @logger.to_s,
        level:        {level_value: @level.value, level_name: @level.name},
        time:         @time.to_s,
        pid:          @pid,
        exception:    @exception,
        options:      @options,
        content:      self.content,
        content_proc: nil
      }
    end

    def self.convert_exception(exc)
      if exc.is_a? Exception
        return {
          exc_class:     exc.exception.class,
          exc_message:   exc.exception.message,
          exc_backtrace: exc.exception.backtrace
        }
      else
        return exc
      end
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

  end  # class Message
end # module Logbert
