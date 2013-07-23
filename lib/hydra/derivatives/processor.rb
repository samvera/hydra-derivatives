module Hydra
  module Derivatives
    class Processor
      attr_accessor :object, :source_name, :directive

      def initialize(obj, source_name, directive)
        self.object = obj
        self.source_name = source_name
        self.directive = directive
      end

      def process
        raise "Processor is an abstract class. Implement `process' on #{self.class.name}"
      end

      def output_datastream_id(name)
        [source_name, name].join('_')
      end

      def output_datastream(dsid)
        # first, check for a defined datastream
        output_datastream = if object.datastreams[dsid]
          object.datastreams[dsid]
        else
          ds = ActiveFedora::Datastream.new(object.inner_object, dsid)
          object.add_datastream(ds)
          ds
        end
      end

      def source_datastream
        object.datastreams[source_name.to_s]
      end

    end
  end
end

