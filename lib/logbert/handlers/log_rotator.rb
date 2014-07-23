require 'fileutils'
require 'logbert/handlers/base_handler'
require 'lockfile'

module Logbert
  module Handlers

    ###########################################################################
    #                          Default Time Formatter                         #
    ###########################################################################
    class LocaltimeFormatter

      attr_accessor :format

      def initialize(format = "%Y-%m-%d-%H%M")
        @format = format
      end

      def format(time)
        time.strftime(@format)
      end

    end # end class LocaltimeFormatter

    ###########################################################################
    # This class is a custom Handler responsible for rotating logs. This      #
    # means that it will periodically:                                        #
    # * Close the current log file and rename it.                             #
    # * Begin writing future log messages to a new file.                      #
    # * Delete the oldest log files to free up space                          #
    # Time-based log rotation                                                 #
    ###########################################################################
    class LogRotator < Logbert::Handlers::BaseHandler

      attr_reader :file_handle, :timestamp_formatter, :interval
      attr_reader :creation_timestamp, :expiration_timestamp, :max_logs
      attr_reader :path
      Lockfile.debug = true

      def initialize(path, options = {})
        @path                = path
        @max_logs            = options.fetch(:max_logs, 5)
        @timestamp_formatter = options.fetch(:timestamp_formatter, LocaltimeFormatter.new)
        @interval            = options.fetch(:interval, (24 * 60 * 60))

      end

      def attached?
        return !file_handle.nil?
      end

      def lock_file_name_for(log_path)
        return "#{log_path}.lock"
      end

      def rotation_required?
        Time.now > expiration_timestamp
      end

      def attach!
        # Lockfile.new('file.lock') do
        #   # some code...
        # end

        Lockfile.new(lock_file_name_for(path)) do
          creation_timestamp   = File.creation_timestamp(path)
          expiration_timestamp = compute_expiration_timestamp_from(creation_timestamp)
          file_handle          = File.open(path, "a")
        end
      end

      def write_message(msg)
        # TODO
      end

      def swap!
        # TODO
      end

      # def rotate_log!
      #   if @stream and not @stream.closed?
      #     @stream.close
      #   end

      #   if File.exists? @path
      #     FileUtils.mv @path, archive_destination
      #   end

      #   @stream = File.open(@path, "ab")

      #   @expiration_time = Time.now + @interval
      # end

      # def emit(output)
      #   rotate_log! if rotation_needed?
      #   @stream.puts output
      #   @stream.flush
      # end

      # private

      # def archive_destination
      #   timestamp = @timestamp_formatter.format(File.ctime(@path))
      #   dest = "#{path}.#{timestamp}"
      #   return dest
      # end

    end # end class LogRotator

  end # end module Handlers
end # end module Logbert
