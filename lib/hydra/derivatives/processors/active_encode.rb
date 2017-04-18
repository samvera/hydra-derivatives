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
    def process
      # TODO: Instead of hard-coding ActiveEncode::Base,
      # pass in or configure the class so that a user can
      # override it with a sub-class of AE::Base.
      encode = ::ActiveEncode::Base.create(source_path, directives)

      # Wait until the encoding job is finished
      sleep Hydra::Derivatives.active_encode_poll_time while encode.reload.running?

      # TODO: Handle timeout
      # https://github.com/projecthydra/hydra-derivatives#processing-timeouts

      raise ActiveEncodeError.new(encode.state, source_path, encode.errors) unless encode.completed?

      # TODO: call output_file_service with the output url
    end
  end
end
