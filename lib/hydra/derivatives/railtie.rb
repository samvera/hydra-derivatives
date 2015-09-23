module Hydra
  module Derivative
    class Railtie < Rails::Railtie
      initializer 'hydra-derivative' do
        require 'hydra-file_characterization'
      end
    end
  end
end