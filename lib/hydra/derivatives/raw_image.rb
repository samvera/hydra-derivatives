require 'mini_magick'

module Hydra
  module Derivatives
    class RawImage < Image
      class_attribute :timeout

      protected

      def create_image(output_file, format, quality=nil)
        xfrm = load_image_transformer
        # Transpose format and scaling due to the fact that ImageMagick can
        # read but not write RAW files and this will otherwise cause many
        # cryptic segmentation faults
        xfrm.format(format)
        yield(xfrm) if block_given?
        xfrm.quality(quality.to_s) if quality
        write_image(output_file, xfrm)
        remove_temp_files(xfrm)
      end

      # Delete any temp files that might clutter up the disk if
      # you are doing a batch or don't touch your temporary storage
      # for a long time
      def remove_temp_files(xfrm)
        xfrm.destroy!
      end
    end
  end
end
