module Hydra::Derivatives
  class ActiveEncodeDerivatives < Runner
    # TODO: object_or_filename - I'm currently passing a String
    # filename during my testing, but we'll probably need to
    # change this so that we can pass in the FileSet or File
    # object that the source file is attached to.
    #
    # @param [String, ActiveFedora::Base] object_or_filename path to the source file, or an object
    # @param [Hash] options options to pass to the encoder
    # @options options [Array] :outputs a list of desired outputs
    def self.create(object_or_filename, options)
      file_name = object_or_filename
      transform_directives(options.delete(:outputs)).each do |instructions|
        processor = processor_class.new(file_name, instructions, output_file_service: output_file_service)
        processor.process
      end
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
