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

    # TODO: Instead of hard-coding ActiveEncode::Base,
    # pass in or configure the class so that a user can
    # override it with a sub-class of AE::Base.
    def process
      encode = ::ActiveEncode::Base.create(source_path, directives)
      timeout ? wait_for_encode_with_timeout(encode) : wait_for_encode(encode)
      # TODO: call output_file_service with the output url
    end

    def wait_for_encode_with_timeout(encode)
      Timeout.timeout(timeout) { wait_for_encode(encode) }
    rescue Timeout::Error
      cleanup_after_timeout(encode)
      raise Hydra::Derivatives::TimeoutError, "Unable to process ActiveEncode derivative\nThe command took longer than #{timeout} seconds to execute"
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
    rescue
      # No-op: We're trying to cancel the encoding because we
      # have already encountered an error.  We want to preserve
      # that timeout error, so don't raise anything here.
    end
  end
end
