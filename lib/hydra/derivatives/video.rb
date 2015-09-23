module Hydra::Derivatives
  module Video
    extend ActiveSupport::Autoload

    eager_autoload do
      autoload :Processor
      autoload :Config
    end
  end
end


