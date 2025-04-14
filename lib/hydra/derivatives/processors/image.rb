# frozen_string_literal: true
require 'mini_magick'
require 'ruby-vips'

module Hydra::Derivatives::Processors
  class Image < Processor
    class_attribute :timeout

    def process
      timeout ? process_with_timeout : create_resized_image
    end

    def process_with_timeout
      Timeout.timeout(timeout) { create_resized_image }
    rescue Timeout::Error
      raise Hydra::Derivatives::TimeoutError, "Unable to process image derivative\nThe command took longer than #{timeout} seconds to execute"
    end

    protected

      # When resizing images, it is necessary to flatten any layers, otherwise the background
      # may be completely black. This happens especially with PDFs. See #110
      def create_resized_image
        if Hydra::Derivatives::ImageService.processor == :graphicsmagick
          create_resized_image_with_graphicsmagick
        elsif Hydra::Derivatives::ImageService.processor == :libvips
          create_resized_image_with_libvips
        else
          create_resized_image_with_imagemagick
        end
      end

      def create_resized_image_with_graphicsmagick
        Hydra::Derivatives::Logger.debug('[ImageProcessor] Using GraphicsMagick image resize method')
        create_image do |temp_file|
          if size
            # remove layers and resize using convert instead of mogrify
            MiniMagick::Tool::Convert.new do |cmd|
              cmd << temp_file.path # input
              cmd.flatten
              cmd.resize(size)
              cmd << temp_file.path # output
            end
          end
        end
      end

      def create_resized_image_with_imagemagick
        Hydra::Derivatives::Logger.debug('[ImageProcessor] Using ImageMagick image resize method')
        create_image do |temp_file|
          if size
            temp_file.flatten
            temp_file.resize(size)
          end
        end
      end

      # rubocop:disable Metrics/MethodLength
      def create_resized_image_with_libvips
        Hydra::Derivatives::Logger.debug('[ImageProcessor] Using libvips resize method')
        create_image do |temp_file|
          if size
            width, height, option = size.match(/(\d+)x(\d+)(.)?/).captures
            # Translate imagemagick resize syntax into ruby-vips
            size_option = case option
                          when '>'
                            :down
                          when '<'
                            :up
                          when '!'
                            :force
                          end
            temp_file.thumbnail_image(width.to_i, height: height.to_i, size: size_option)
          end
        end
      end
      # rubocop:enable Metrics/MethodLength

      def create_image
        if Hydra::Derivatives::ImageService.processor == :libvips
          image = block_given? ? yield(load_image_transformer) : load_image_transformer
          write_image_with_vips(image, directives)
        else
          xfrm = selected_layers(load_image_transformer)
          yield(xfrm) if block_given?
          xfrm.format(directives.fetch(:format))
          xfrm.quality(quality.to_s) if quality
          write_image(xfrm)
        end
      end

      def write_image(xfrm)
        output_io = StringIO.new
        xfrm.write(output_io)
        output_io.rewind
        output_file_service.call(output_io, directives)
      end

      def write_image_with_vips(image, directives)
        output_io = StringIO.new
        format = directives.fetch(:format, "jpg")
        format_string = ".#{format}#{"[Q=#{quality}]" if quality}"
        output_io.write(image.write_to_buffer(format_string))
        output_io.rewind
        output_file_service.call(output_io, directives)
      end

      # Override this method if you want a different transformer, or need to load the
      # raw image from a different source (e.g. external file)
      def load_image_transformer
        if Hydra::Derivatives::ImageService.processor == :libvips
          # Vips specifies pdf layers at load time
          selected_vips_layers(source_path)
        else
          MiniMagick::Image.open(source_path)
        end
      end

    private

      def size
        directives.fetch(:size, nil)
      end

      def quality
        directives.fetch(:quality, nil)
      end

      def selected_layers(image)
        if /pdf/i.match?(image.type)
          image.layers[directives.fetch(:layer, 0)]
        elsif directives.fetch(:layer, false)
          image.layers[directives.fetch(:layer)]
        else
          image
        end
      end

      def selected_vips_layers(source_path)
        if `vipsheader #{Shellwords.escape(source_path)}` =~ /pdfload/i && directives.fetch(:layer, false)
          Vips::Image.new_from_file(source_path, page: directives.fetch(:layer))
        else
          Vips::Image.new_from_file(source_path)
        end
      end
  end
end
