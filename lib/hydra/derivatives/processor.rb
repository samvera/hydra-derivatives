module Hydra
  module Derivatives
    class Processor
      attr_accessor :object, :source_name, :directives, :source_file_service, :output_file_service

      def initialize(obj, source_name, directives, opts={})
        self.object = obj
        self.source_name = source_name
        self.directives = directives
        self.source_file_service = opts.fetch(:source_file_service, Hydra::Derivatives.source_file_service)
        self.output_file_service = opts.fetch(:output_file_service, Hydra::Derivatives.output_file_service)
      end

      def process
        raise "Processor is an abstract class. Implement `process' on #{self.class.name}"
      end

      def output_file_id(name)
        [source_name, name].join('_')
      end

      # @deprecated Please use a PersistOutputFileService class to save an object
      def output_file
        raise NotImplementedError, "Processor is an abstract class. Utilize an implementation of a PersistOutputFileService class in #{self.class.name}"
      end
      
      def source_file
        @source_file ||= source_file_service.call(object, source_name)
      end

    end
  end
end
