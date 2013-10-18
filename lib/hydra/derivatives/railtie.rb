module Hydra::Derivative
  class Railtie < Rails::Railtie
    config.initializer 'hydra-derivative' do
      require 'hydra-file_characterization'
    end
  end
end