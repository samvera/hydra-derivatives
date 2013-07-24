module Hydra
  module Derivatives
    class Audio < Processor
      include Ffmpeg

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

