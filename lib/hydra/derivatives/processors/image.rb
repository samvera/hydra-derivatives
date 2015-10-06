require 'mini_magick'

module Hydra::Derivatives::Processors
  class Image < Processor
    class_attribute :timeout

    def process
      timeout ? process_with_timeout : process_without_timeout
    end

    def process_with_timeout
      status = Timeout::timeout(timeout) do
        process_without_timeout
      end
    rescue Timeout::Error => ex
      raise Hydra::Derivatives::TimeoutError, "Unable to process image derivative\nThe command took longer than #{timeout} seconds to execute"
    end

    def process_without_timeout
      format = directives.fetch(:format)
      name = directives.fetch(:label, format)
      destination_name = output_filename_for(name)
      size = directives.fetch(:size, nil)
      quality = directives.fetch(:quality, nil)
      create_resized_image(destination_name, size, format, quality)
    end

    protected

    def create_resized_image(destination_name, size, format, quality=nil)
      create_image(destination_name, format, quality) do |xfrm|
        xfrm.resize(size) if size.present?
      end
    end

    def create_image(destination_name, format, quality=nil)
      xfrm = load_image_transformer
      yield(xfrm) if block_given?
      xfrm.format(format)
      xfrm.quality(quality.to_s) if quality
      write_image(destination_name, format, xfrm)
    end

    def write_image(destination_name, format, xfrm)
      output_io = StringIO.new
      xfrm.write(output_io)
      output_io.rewind

      output_file_service.call(output_io, directives)
    end

    # Override this method if you want a different transformer, or need to load the
    # raw image from a different source (e.g. external file)
    def load_image_transformer
      MiniMagick::Image.open(source_path)
    end
  end
end
