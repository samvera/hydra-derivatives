require 'mini_magick'
module Hydra
  module Derivatives
    class Image < Processor
      def process
        directives.each do |name, args| 
          opts = args.kind_of?(Hash) ? args : {size: args}
          format = opts.fetch(:format, 'png')
          output_datastream_name = opts.fetch(:datastream, output_datastream_id(name))
          create_resized_image(output_datastream(output_datastream_name), opts[:size], format)
        end
      end

      protected

      def new_mime_type(format)
        MIME::Types.type_for(format).first.to_s
      end

      def create_resized_image(output_datastream, size, format, quality=nil)
        create_image(output_datastream, format, quality) do |xfrm|
          xfrm.resize(size) if size.present?
        end
        output_datastream.mime_type = new_mime_type(format)
      end

      def create_image(output_datastream, format, quality=nil)
        xfrm = load_image_transformer
        yield(xfrm) if block_given?
        xfrm.format(format)
        xfrm.quality(quality.to_s) if quality
        write_image(output_datastream, xfrm)
      end

      def write_image(output_datastream, xfrm)
        stream = StringIO.new
        xfrm.write(stream)
        stream.rewind
        output_datastream.content = stream
      end

      # Override this method if you want a different transformer, or need to load the 
      # raw image from a different source (e.g.  external datastream)
      def load_image_transformer
        MiniMagick::Image.read(source_datastream.content)
      end
    end
  end
end
