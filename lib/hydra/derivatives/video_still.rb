module Hydra
  module Derivatives
    class VideoStill < Processor
      include Ffmpeg

      def encode(path, options, output_file)
        movie = FFMPEG::Movie.new(path)
        movie.screenshot(output_file, options)
      end

      protected

      def options_for(format)
        "-ss #{time_offset} -s #{size_attributes} -vframes 1 -f image2"
      end

      def size_attributes
        "320x240"
      end

      def time_offset
        "5"
      end

      def new_mime_type(format)
        "image/#{format}"
      end
    end
  end
end
