module Hydra
  module Derivatives
    class DocumentDerivatives < Runner
      def self.processor_class
        Document
      end
    end
  end
end
