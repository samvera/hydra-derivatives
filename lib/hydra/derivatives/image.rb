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

      def create_resized_image(output_ds, size, format, quality=nil)
        create_image(output_ds, format, quality) do |xfrm|
          if size
            xfrm.change_geometry!(size) do |cols, rows, img|
             img.resize!(cols, rows)
            end
          end
        end
        output_ds.mimeType = new_mime_type(format)
      end

      def create_image(output_datastream, format, quality=nil)
        xfrm = load_image_transformer
        yield(xfrm) if block_given?
        output_datastream.content = if quality
          xfrm.to_blob { self.quality = quality; self.format = format.upcase }
        else
          xfrm.to_blob { self.format = format.upcase }
        end
      end

      # Override this method if you want a different transformer, or need to load the 
      # raw image from a different source (e.g.  external datastream)
      def load_image_transformer
        Magick::ImageList.new.tap do |xformer|
          xformer.from_blob(source_datastream.content)
        end
      end
    end
  end
end
