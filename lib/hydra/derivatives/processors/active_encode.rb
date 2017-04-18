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
      encode = ::ActiveEncode::Base.create(source_path, directives)

      # TODO: Instead of hard-coding sleep time, make a config

      # Wait until the encoding job is finished
      sleep 10 while encode.reload.running?

      # TODO: Handle timeout
      # https://github.com/projecthydra/hydra-derivatives#processing-timeouts

      raise ActiveEncodeError.new(encode.state, source_path, encode.errors) unless encode.completed?

      # TODO: call output_file_service with the output url
    end
  end
end
