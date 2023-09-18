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

    def self.cli
      case processor
      when :graphicsmagick
        :graphicsmagick
      when :imagemagick
        :imagemagick
      end
    end

    def self.external_convert_command
      case processor
      when :graphicsmagick
        'gm convert'
      when :imagemagick
        'convert'
      end
    end

    def self.external_identify_command
      case processor
      when :graphicsmagick
        'gm identify'
      when :imagemagick
        'identify'
      end
    end
  end
end
