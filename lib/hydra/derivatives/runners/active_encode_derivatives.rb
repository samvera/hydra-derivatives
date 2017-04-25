module Hydra::Derivatives
  class ActiveEncodeDerivatives < Runner
    # @param [String, ActiveFedora::Base] object_or_filename source file name (or path), or an object that has a method that will return the file name
    # @param [Hash] options options to pass to the encoder
    # @option options [Symbol] :source a method that can be called on the object to retrieve the source file's name
    # @options options [Array] :outputs a list of desired outputs
    def self.create(object_or_filename, options)
      source_file(object_or_filename, options) do |file_name|
        transform_directives(options.delete(:outputs)).each do |instructions|
          processor = processor_class.new(file_name, instructions, output_file_service: output_file_service)
          processor.process
        end
      end
    end

    # Use the source service configured for this class or default to the remote file service
    def self.source_file_service
      @source_file_service || RemoteSourceFile
    end

    # Use the output service configured for this class or default to the null output service
    def self.output_file_service
      @output_file_service || PersistExternalFileOutputFileService
    end

    def self.processor_class
      Processors::ActiveEncode
    end
  end
end
