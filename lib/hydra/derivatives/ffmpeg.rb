# An abstract class for asyncronous jobs that transcode files using FFMpeg

require 'tmpdir'
require 'open3'

module Hydra
  module Derivatives
    module Ffmpeg
      extend ActiveSupport::Concern

      INPUT_OPTIONS=:input_options
      OUTPUT_OPTIONS=:output_options

      included do
        include ShellBasedProcessor
      end


      module ClassMethods

        def encode(path, options, output_file)
          inopts = options[INPUT_OPTIONS] ||= "-y"
          outopts = options[OUTPUT_OPTIONS] ||= ""
          execute "#{Hydra::Derivatives.ffmpeg_path} #{inopts} -i \"#{path}\" #{outopts} #{output_file}"
        end
      end

    end
  end
end

