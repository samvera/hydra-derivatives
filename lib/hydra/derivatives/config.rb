module Hydra
  module Derivatives
    class Config
      attr_writer :ffmpeg_path, :libreoffice_path, :temp_file_base, :fits_path, :enable_ffmpeg, :video_codec
      def ffmpeg_path
        @ffmpeg_path ||= 'ffmpeg'
      end

      def libreoffice_path
        @libreoffice_path ||= 'soffice'
      end

      def temp_file_base
        @temp_file_base ||= '/tmp'
      end

      def fits_path
        @fits_path ||= 'fits.sh'
      end

      def enable_ffmpeg
        @enable_ffmpeg ||= true
      end

      def video_codec
        @video_codec ||= {mp4:"-vcodec libx264 -acodec libfdk_aac",
                          webm:"-vcodec libvpx -acodec libvorbis",
                          mvk:"-vcodec ffv1",
                          jpg:"-vcodec mjpeg" }
      end

    end
  end
end
