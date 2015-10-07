require 'active_fedora'
require 'deprecation'

module Hydra
  module Derivatives
    extend ActiveSupport::Concern
    extend ActiveSupport::Autoload
    extend Deprecation
    self.deprecation_horizon = "hydra-derivatives 1.0"

    # Runners take a single input and produce one or more outputs
    # The runner typically accomplishes this by using one or more processors
    autoload_under 'runners' do
      autoload :AudioDerivatives
      autoload :DocumentDerivatives
      autoload :FullTextExtract
      autoload :ImageDerivatives
      autoload :Jpeg2kImageDerivatives
      autoload :PdfDerivatives
      autoload :Runner
      autoload :VideoDerivatives
    end

    autoload :Processors
    autoload :Config
    autoload :Logger
    autoload :TempfileService
    autoload :IoDecorator

    autoload_under 'services' do
      autoload :RetrieveSourceFileService
      autoload :PersistOutputFileService
      autoload :PersistBasicContainedOutputFileService
      autoload :TempfileService
      autoload :MimeTypeService
    end

    # Raised if the timout elapses
    class TimeoutError < ::Timeout::Error; end

    def self.config
      @config ||= reset_config!
    end

    def self.reset_config!
      @config = Config.new
    end

    [:ffmpeg_path, :libreoffice_path, :temp_file_base, :fits_path, :kdu_compress_path,
      :kdu_compress_recipes, :enable_ffmpeg, :source_file_service, :output_file_service].each do |method|
      module_eval <<-RUBY
        def self.#{method.to_s}
          config.#{method.to_s}
        end
        def self.#{method.to_s}= val
          config.#{method.to_s}= val
        end
      RUBY
    end

    included do
      class_attribute :source_file_service
      self.source_file_service = Hydra::Derivatives.source_file_service
    end
  end
end
