module Hydra
  module Derivatives
    class Config
      attr_writer :ffmpeg_path, :libreoffice_path, :temp_file_base, :fits_path, :enable_ffmpeg
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

    end
  end
end
