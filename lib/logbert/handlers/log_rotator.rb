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

    end # class LocaltimeFormatter

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
        return Time.now > @expiration_timestamp
      end

      def already_rotated?
        return @creation_timestamp <= @expiration_timestamp
      end

      def attach_to_logfile!
        Lockfile.new(lock_file_name_for(@path)) do
          @creation_timestamp   = File.ctime(path)
          @expiration_timestamp = compute_expiration_timestamp_from(@creation_timestamp)
          @file_handle          = File.open(@path, 'a')
        end
      end

      def write_message(msg)
        attach_to_logfile! unless attached?
        rotate_logs! if rotation_required?
        emit(msg)
      end

      def emit(output)
        @file_handle.puts output
        @file_handle.flush
      end

      def compute_expiration_timestamp_from(timestamp)
        return timestamp + @interval
      end

      def rotate_logs!
        performed_swap = false

        Lockfile.new(lock_file_name_for(@path)) do
          # Double-check that the file wasn't already rotated
          unless already_rotated?
            performed_swap = true

            # Close the old log
            if @file_handle and not @file_handle.closed?
              @file_handle.close
            end

            # Rename the old log
            if File.exists? @path
              FileUtils.mv @path, archive_destination
            end

            # Set the file handle to nil now
            @file_handle = nil
          end
        end # Lockfile lock

        attach_to_logfile! unless attached?

        # Post-Processing logic if the rotation was performed
        post_process if performed_swap
      end

      def post_process
        # TODO
      end

      def archive_destination
        timestamp = @timestamp_formatter.format(@creation_timestamp)
        dest = "#{@path}.backup.#{timestamp}"
        return dest
      end

      private :archive_destination, :post_process
    end # class LogRotator

  end # module Handlers
end # module Logbert
