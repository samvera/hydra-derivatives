require 'active_encode'

module Hydra::Derivatives::Processors
  class ActiveEncode < Processor
    def process
      encode = ::ActiveEncode::Base.create(source_path, directives)

      # TODO wait until the encode job succeeds then call output_file_service with the output url
      # while(encode.reload.running?) do
      #   p "Wait: #{Time.now}"
      #   sleep 10
      # end

      raise_exception_if_encoding_failed(encode)
    end

    def raise_exception_if_encoding_failed(encode)
      return unless encode.failed?
      raise StandardError.new("Encoding failed: #{encode.errors.join(' ; ')}")
    end

  end
end
