# frozen_string_literal: true
module Hydra::Derivatives
  module ImageService
    def self.default_processor
      :imagemagick
    end

    def self.processor
      case ENV['IMAGE_PROCESSOR']
      when 'imagemagick'
        Hydra::Derivatives::Logger.debug('[ImageProcessor] Using ImageMagick as image processor')
        :imagemagick
      when 'graphicsmagick'
        Hydra::Derivatives::Logger.debug('[ImageProcessor] Using GraphicsMagick as image processor')
        :graphicsmagick
      else
        Hydra::Derivatives::Logger.debug("[ImageProcessor] The environment variable IMAGE_PROCESSOR should be set to either 'imagemagick' or 'graphicsmagick'. It is currently set to: #{ENV['IMAGE_PROCESSOR']}. Defaulting to using #{default_processor}")
        default_processor
      end
    end
  end
end
