module Hydra
  module Derivatives
    class Video < Processor
      include Ffmpeg
      def process
        directive.each do |name, args| 
          raise ArgumentError, "You must provide the :format you want to transcode into. You provided #{args}" unless args[:format]
          # TODO if the source is in the correct format, we could just copy it and skip transcoding.
          encode_datastream(output_datastream_id(name), args[:format], new_mime_type(args[:format]), options_for(args[:format]))
        end
      end


      protected

      def options_for(format)
        "-s #{size_attributes} #{video_attributes} #{codecs(format)} #{audio_attributes}"
      end

      def video_bitrate
        '345k'
      end

      def video_attributes
        "-g 30 -b:v #{video_bitrate}"
      end

      def size_attributes
        "320x240"
      end

      def audio_attributes 
        "-ac 2 -ab 96k -ar 44100"
      end

      def codecs(format)
        case format
        when 'mp4'
          "-vcodec libx264 -acodec libfaac"
        when 'webm'
          "-acodec libvorbis"
        else
          raise ArgumentError, "Unknown format `#{format}'"
        end
      end

      def new_mime_type(format)
        "video/#{format}"
      end
    end
  end
end


