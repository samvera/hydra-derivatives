# An abstract class for asyncronous jobs that transcode files using FFMpeg

require 'tmpdir'
require 'open3'

module Hydra
  module Derivatives
    module Ffmpeg
      extend ActiveSupport::Concern

      included do
        include ShellBasedProcessor
      end


      module ClassMethods

        def encode(path, options, output_file)
          execute "#{Hydra::Derivatives.ffmpeg_path} -y -i \"#{path}\" #{options} #{output_file}"
        end
      end

    end
  end
end

