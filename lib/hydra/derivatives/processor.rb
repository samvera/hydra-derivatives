module Hydra
  module Derivatives
    class Processor
      attr_accessor :object, :source_name, :directives

      def initialize(obj, source_name, directives)
        self.object = obj
        self.source_name = source_name
        self.directives = directives
      end

      def process
        raise "Processor is an abstract class. Implement `process' on #{self.class.name}"
      end

      def output_file_id(name)
        [source_name, name].join('_')
      end

      def output_file(dsid)
        # first, check for a defined file
        output_file = if object.attached_files[dsid]
          object.attached_files[dsid]
        else
          ds = ActiveFedora::Datastream.new(object, dsid)
          object.attach_file(ds, dsid)
          ds
        end
      end

      def source_file
        object.attached_files[source_name.to_s]
      end

    end
  end
end

