module Hydra::Derivatives
  module Processors
    extend ActiveSupport::Autoload

    eager_autoload do
      autoload :Processor
    end
    autoload :Image
    autoload :Ffmpeg
    autoload :Video
    autoload :Audio
    autoload :Document
    autoload :ShellBasedProcessor
    autoload :Jpeg2kImage
    autoload :RawImage
  end
end
