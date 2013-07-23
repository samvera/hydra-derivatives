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
    end
  end
end

