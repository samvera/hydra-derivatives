module Hydra::Derivatives::Processors
  module Video
    class Processor < Hydra::Derivatives::Processors::Processor
      include Ffmpeg

      class_attribute :config
      self.config = Config.new

      protected
      def options_for(format)
        output_options = "-s #{@directives[:size].nil? ? config.size_attributes : @directives[:size]} "
        output_options += "#{codecs(format)}"
        if format == "jpg"
          input_options = " -itsoffset -2"
          output_options += " -vframes 1 -an -f rawvideo"
        else
          input_options = @directives[:input_options].nil? ? "" : @directives[:input_options]
          output_options += " #{@directives[:video].nil? ? config.video_attributes : @directives[:video]}"
          output_options += " #{@directives[:audio].nil? ? config.audio_attributes : @directives[:audio]}"
        end

        { Ffmpeg::OUTPUT_OPTIONS => output_options, Ffmpeg::INPUT_OPTIONS => input_options }
      end


        def codecs(format)
          case format
          when 'mp4'
            config.mpeg4.codec
          when 'webm'
            config.webm.codec
          when "mkv"
            config.mkv.codec
          when "jpg"
            config.jpeg.codec
          else
            raise ArgumentError, "Unknown format `#{format}'"
          end
        end
    end
  end
end
