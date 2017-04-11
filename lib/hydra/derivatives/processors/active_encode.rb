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

      # Wait until the encoding job is finished
      # while(encode.reload.running?) { sleep 10 }

      raise ActiveEncodeError.new(encode.state, source_path, encode.errors) unless encode.completed?

      # TODO: call output_file_service with the output url
    end
  end
end
