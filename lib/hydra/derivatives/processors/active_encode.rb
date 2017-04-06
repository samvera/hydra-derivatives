require 'active_encode'

module Hydra::Derivatives::Processors
  class ActiveEncode < Processor
    def process
      encode = ::ActiveEncode::Base.create(source_path, directives)

      # Wait until the encoding job is finished
      # while(encode.reload.running?) { sleep 10 }

      raise_exception_if_encoding_failed(encode)
      raise_exception_if_encoding_cancelled(encode)

      # TODO: call output_file_service with the output url
    end

    def raise_exception_if_encoding_failed(encode)
      return unless encode.failed?
      raise StandardError.new("Encoding failed for #{source_path}: #{encode.errors.join(' ; ')}")
    end

    def raise_exception_if_encoding_cancelled(encode)
      return unless encode.cancelled?
      raise StandardError.new("Encoding cancelled for #{source_path}")
    end
  end
end
