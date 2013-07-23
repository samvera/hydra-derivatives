module Hydra
  module Derivatives
    class Video < Processor
      include Ffmpeg

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


