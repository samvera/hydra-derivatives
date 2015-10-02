require 'active_fedora'
require 'deprecation'

module Hydra
  module Derivatives
    extend ActiveSupport::Concern
    extend ActiveSupport::Autoload
    extend Deprecation
    self.deprecation_horizon = "hydra-derivatives 1.0"

    autoload_under 'runners' do
      autoload :AudioDerivatives
      autoload :DocumentDerivatives
      autoload :ImageDerivatives
      autoload :Jpeg2kImageDerivatives
      autoload :PdfDerivatives
      autoload :Runner
      autoload :VideoDerivatives
    end

    autoload :Processor
    autoload :Image
    autoload :Ffmpeg
    autoload :Video
    autoload :Audio
    autoload :Config
    autoload :Document
    autoload :ShellBasedProcessor
    autoload :Jpeg2kImage
    autoload :RawImage
    autoload :Logger
    autoload :TempfileService
    autoload :IoDecorator

    # services
    autoload :RetrieveSourceFileService,         'hydra/derivatives/services/retrieve_source_file_service'
    autoload :PersistOutputFileService,          'hydra/derivatives/services/persist_output_file_service'
    autoload :PersistBasicContainedOutputFileService, 'hydra/derivatives/services/persist_basic_contained_output_file_service'
    autoload :TempfileService,                   'hydra/derivatives/services/tempfile_service'

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
