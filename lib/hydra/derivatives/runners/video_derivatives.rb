module Hydra
  module Derivatives
    class VideoDerivatives < Runner
      def self.processor_class
        Video::Processor
      end
    end
  end
end
