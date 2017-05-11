require 'active_encode'

module Hydra::Derivatives::Processors
  class ActiveEncodeError < StandardError
    def initialize(status, source_path, errors = [])
      msg = "ActiveEncode status was \"#{status}\" for #{source_path}"
      msg = "#{msg}: #{errors.join(' ; ')}" unless errors.empty?
      super(msg)
    end
  end

  class ActiveEncode < Processor
    class_attribute :timeout
    attr_accessor :encode_class

    def initialize(source_path, directives, opts = {})
      super
      @encode_class = opts.delete(:encode_class) || ::ActiveEncode::Base
    end

    def process
      encode = encode_class.create(source_path, directives)
      timeout ? wait_for_encode_with_timeout(encode) : wait_for_encode(encode)
      encode.output.each do |output|
        output_file_service.call(output, directives)
      end
    end

    private

      def wait_for_encode_with_timeout(encode)
        Timeout.timeout(timeout) { wait_for_encode(encode) }
      rescue Timeout::Error
        cleanup_after_timeout(encode)
      end

      # Wait until the encoding job is finished.  If the status
      # is anything other than 'completed', raise an error.
      def wait_for_encode(encode)
        sleep Hydra::Derivatives.active_encode_poll_time while encode.reload.running?
        raise ActiveEncodeError.new(encode.state, source_path, encode.errors) unless encode.completed?
      end

      # After a timeout error, try to cancel the encoding.
      def cleanup_after_timeout(encode)
        encode.cancel!
      rescue => e
        cancel_error = e
      ensure
        msg = "Unable to process ActiveEncode derivative: The command took longer than #{timeout} seconds to execute. Encoding will be cancelled."
        msg = "#{msg} An error occurred while trying to cancel encoding: #{cancel_error}" if cancel_error
        raise Hydra::Derivatives::TimeoutError, msg
      end
  end
end
