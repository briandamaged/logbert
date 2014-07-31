require 'fileutils'
require 'logbert/handlers/base_handler'
require 'lockfile'
require 'zlib'

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
      attr_reader :expiration_timestamp, :max_backups
      attr_reader :path

      def initialize(path, options = {})
        @path                = path
        @max_backups         = options.fetch(:max_backups, nil)
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
        return File.ctime(@path) > @expiration_timestamp
      end

      def attach_to_logfile!
        lock do
          dirname               = File.dirname(File.absolute_path(@path))
          FileUtils.mkdir_p dirname unless File.exists? dirname
          @file_handle          = File.open(@path, 'a')
          creation_timestamp    = File.ctime(@path)
          @expiration_timestamp = compute_expiration_timestamp_from(creation_timestamp)
        end
      end

      def emit(output)
        attach_to_logfile! unless attached?
        rotate_logs! if rotation_required?
        @file_handle.puts output
        @file_handle.flush
      end

      def compute_expiration_timestamp_from(timestamp)
        return timestamp + @interval
      end

      def lock(&block)
        Lockfile.new(lock_file_name_for(@path)) do
          block.call
        end
      end

      def rotate_logs!
        performed_swap = false

        lock do
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

          end
        end # Lockfile lock

        attach_to_logfile!

        # Post-Processing logic if the rotation was performed
        post_process if performed_swap
      end

      # This will essentially perform at most two things:
      # 1.) Compress older log files
      # 2.) Delete, if any, old log files based upon max_backups
      def post_process
        compress_backups
        delete_backups
      end

      def compress_backups
        # Compress older log files (unless already compressed)
        get_old_logs.each do |log|
          unless File.extname(log) == ".gz"
            # Compress the file
            gzip(log)
            # Delete the actual log file
            File.delete(log)
          end
        end
      end

      def delete_backups
        # Delete, if any, old log files based upon max_backups
        unless @max_backups.nil?
          # Grab all the logs.  Sort from newest to oldest
          old_logs = get_old_logs.sort_by {|f| File.ctime(f)}.reverse[@max_backups..-1]

          # If we have more than max_backups logs, then delete the extras
          old_logs.each {|f| File.delete(f)} if old_logs
        end
      end

      def gzip(file)
        Zlib::GzipWriter.open("#{file}.gz") do |gz|
          gz.mtime = File.mtime(file)
          gz.orig_name = file
          gz.write IO.binread(file)
          gz.close
        end
      end

      def get_old_logs
        absolute_dir = File.dirname(File.absolute_path(@path))
        older_files = Dir[File.join(absolute_dir, "#{@path}.backup.*")]
        return older_files
      end

      def archive_destination
        timestamp = @timestamp_formatter.format(File.ctime(@path))
        dest = "#{@path}.backup.#{timestamp}"
        return dest
      end

      private :archive_destination, :post_process
    end # class LogRotator

  end # module Handlers
end # module Logbert
