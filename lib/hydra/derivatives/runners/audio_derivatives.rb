module Hydra
  module Derivatives
    class AudioDerivatives < Runner
      def self.processor_class
        Audio
      end
    end
  end
end
