module Hydra
  module Derivatives
    class Processor
      attr_accessor :source_path, :directives, :output_file_service

      def initialize(source_path, directives, opts={})
        self.source_path = source_path
        self.directives = directives
        self.output_file_service = opts.fetch(:output_file_service, Hydra::Derivatives.output_file_service)
      end

      def process
        raise "Processor is an abstract class. Implement `process' on #{self.class.name}"
      end

      # This governs the output key sent to the persist file service
      # while this is adequate for storing in Fedora, it's not a great name for saving
      # to the file system.
      def output_file_id(name)
        [out_prefix, name].join('_')
      end

      def output_filename_for(_name)
        File.basename(source_path)
      end

      # @deprecated Please use a PersistOutputFileService class to save an object
      def output_file
        raise NotImplementedError, "Processor is an abstract class. Utilize an implementation of a PersistOutputFileService class in #{self.class.name}"
      end
    end
  end
end
