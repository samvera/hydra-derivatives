module Hydra
  module Derivatives
    class Processor
      attr_accessor :object, :source_path, :out_prefix, :directives, :output_file_service

      def initialize(obj, source_path, out_prefix, directives, opts={})
        self.object = obj
        self.source_path = source_path
        self.out_prefix = out_prefix
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

      # @deprecated Please use a PersistOutputFileService class to save an object
      def output_file
        raise NotImplementedError, "Processor is an abstract class. Utilize an implementation of a PersistOutputFileService class in #{self.class.name}"
      end
    end
  end
end
