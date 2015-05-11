# An abstract class for asyncronous jobs that transcode files using FFMpeg

require 'tmpdir'
require 'open3'

module Hydra
  module Derivatives
    module ShellBasedProcessor
      extend ActiveSupport::Concern

      included do
        class_attribute :timeout
        extend Open3
      end

      def process
        directives.each do |name, args|
          format = args[:format]
          raise ArgumentError, "You must provide the :format you want to transcode into. You provided #{args}" unless format
          # TODO if the source is in the correct format, we could just copy it and skip transcoding.
          output_file_name = args[:datastream] || output_file_id(name)
          encode_file(output_file_name, format, new_mime_type(format), options_for(format))
        end
      end

      # override this method in subclass if you want to provide specific options.
      # returns a hash of options that the specific processors use
      def options_for(format)
        {}
      end

      def encode_file(dest_path, file_suffix, mime_type, options)
        out_file = nil
        output_file = Dir::Tmpname.create(['sufia', ".#{file_suffix}"], Hydra::Derivatives.temp_file_base){}
        Hydra::Derivatives::TempfileService.create(source_file) do |f|
          self.class.encode(f.path, options, output_file)
        end
        out_file = File.open(output_file, "rb")
        object.add_file(out_file.read, path: dest_path, mime_type: mime_type)
        File.unlink(output_file)
      end

      module ClassMethods

        def execute(command)
          context = {}
          if timeout
            execute_with_timeout(timeout, command, context)
          else
            execute_without_timeout(command, context)
          end
        end

        def execute_with_timeout(timeout, command, context)
          begin
            status = Timeout::timeout(timeout) do
              execute_without_timeout(command, context)
            end
          rescue Timeout::Error => ex
            pid = context[:pid]
            Process.kill("KILL", pid)
            raise Hydra::Derivatives::TimeoutError, "Unable to execute command \"#{command}\"\nThe command took longer than #{timeout} seconds to execute"
          end

        end

        def execute_without_timeout(command, context)
          stdin, stdout, stderr, wait_thr = popen3(command)
          context[:pid] = wait_thr[:pid]
          stdin.close
          out = stdout.read
          stdout.close
          err = stderr.read
          stderr.close
          raise "Unable to execute command \"#{command}\"\n#{err}" unless wait_thr.value.success?
        end
      end
    end
  end
end
