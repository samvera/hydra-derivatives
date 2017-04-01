module Hydra::Derivatives
  class ActiveEncodeDerivatives < Runner
    # @param [String, ActiveFedora::Base] object_or_filename path to the source file, or an object
    # @param [Hash] options options to pass to the encoder
    # @options options [Array] :outputs a list of desired outputs, each entry is a hash that has :label (optional), :format and :url
    def self.create(object_or_filename, options)
      source_file(object_or_filename, options) do |f|
        instructions = transform_directives(options)
        processor_class.new(f,
                            instructions.merge(source_file_service: source_file_service),
                            output_file_service: output_file_service).process
      end
    end

    # Use the source service configured for this class or default to the uri source service
    def self.source_file_service
      @output_file_service || UriSourceFileService
    end

    # Use the output service configured for this class or default to the null output service
    def self.output_file_service
      @output_file_service || NullOutputFileService
    end

    def self.processor_class
      Processors::ActiveEncode
    end
  end
end
