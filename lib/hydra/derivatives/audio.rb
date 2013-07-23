module Hydra
  module Derivatives
    class Audio < Processor
      include Ffmpeg
      def process
        directive.each do |name, args| 
          raise ArgumentError, "You must provide the :format you want to transcode into. You provided #{args}" unless args[:format]
          # TODO if the source is in the correct format, we could just copy it and skip transcoding.
          encode_datastream(output_datastream_id(name), args[:format], new_mime_type(args[:format]))
        end
      end


      protected

      def new_mime_type(format)
        case format
        when 'mp3'
          "audio/mpeg"
        else
          "audio/#{format}"
        end
      end
    end
  end
end

