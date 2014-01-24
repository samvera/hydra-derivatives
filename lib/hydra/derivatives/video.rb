module Hydra
  module Derivatives
    class Video < Processor
      include Ffmpeg

      protected

      def options_for(format)
        input_options=""
        output_options = "-s #{size_attributes} #{codecs(format)}"

        if (format == "jpg")
          input_options +=" -itsoffset -2"
          output_options+= " -vframes 1 -an -f rawvideo"
        else
          output_options +=" #{video_attributes} #{audio_attributes}"
        end

        { Ffmpeg::OUTPUT_OPTIONS => output_options, Ffmpeg::INPUT_OPTIONS => input_options}
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
          "-vcodec libx264 -acodec libfdk_aac"
        when 'webm'
          "-vcodec libvpx -acodec libvorbis"
        when "mkv"
          "-vcodec ffv1"
        when "jpg"
          "-vcodec mjpeg"
        else
          raise ArgumentError, "Unknown format `#{format}'"
        end
      end

      def new_mime_type(format)
        format == "jpg" ? "image/jpeg" : "video/#{format}"
      end
    end
  end
end


