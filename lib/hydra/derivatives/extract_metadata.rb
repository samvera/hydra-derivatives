require 'open3'
module Hydra
  module Derivatives
    module ExtractMetadata
      include Open3

      def extract_metadata
        out = nil
        to_tempfile do |f|
          out = run_fits!(f.path)
        end
        out
      end

      def to_tempfile(&block)
        return unless has_content?
        type = MIME::Types[mimeType].first
        logger.warn "Unable to find a registered mime type for #{mimeType.inspect} on #{pid}" unless type
        extension = type ? ".#{type.extensions.first}" : ''

        Tempfile.open(["#{pid}-#{dsVersionID}", extension]) do |f|
          f.binmode
          if content.respond_to? :read
            f.write(content.read)
          else
            f.write(content)
          end
          content.rewind if content.respond_to? :rewind
          yield(f)
        end
      end

      private 


        def run_fits!(file_path)
            command = "#{fits_path} -i \"#{file_path}\""
            stdin, stdout, stderr, wait_thr = popen3(command)
            stdin.close
            out = stdout.read
            stdout.close
            err = stderr.read
            stderr.close
            exit_status = wait_thr.value
            raise "Unable to execute command \"#{command}\"\n#{err}" unless exit_status.success?
            out
        end


        def fits_path
          Hydra::Derivatives.fits_path
        end

      end
    end
end

