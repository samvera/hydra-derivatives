require 'active_fedora'
require 'hydra/derivatives/railtie' if defined?(Rails)
require 'deprecation'
module Hydra
  module Derivatives
    extend ActiveSupport::Concern
    extend ActiveSupport::Autoload
    extend Deprecation
    self.deprecation_horizon = "hydra-derivatives 1.0"

    autoload :Processor
    autoload :Image
    autoload :Ffmpeg
    autoload :Video
    autoload :Audio
    autoload :Config
    autoload :Document
    autoload :ExtractMetadata
    autoload :ShellBasedProcessor
    autoload :Jpeg2kImage
    autoload :RawImage
    autoload :Logger
    autoload :MimeTypes
    autoload :TempfileService

    # Raised if the timout elapses
    class TimeoutError < ::Timeout::Error; end

    def self.config
      @config ||= reset_config!
    end

    def self.reset_config!
      @config = Config.new
    end

    [:ffmpeg_path, :libreoffice_path, :temp_file_base, :fits_path, :kdu_compress_path,
      :kdu_compress_recipes, :enable_ffmpeg].each do |method|
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
      class_attribute :transformation_schemes
    end

    # Runs all of the transformations immediately.
    # You may want to run this job in the background as it may take a long time.
    def create_derivatives
      if transformation_schemes.present?
        transformation_schemes.each do |transform_scheme|
          if transform_scheme.instance_of?(Proc)
            transform_scheme.call(self)
          else
            send(transform_scheme)
          end
        end
      else
        logger.warn "`create_derivatives' was called on an instance of #{self.class}, but no derivatives have been requested"
      end
    end

    # Create derivatives from a file according to transformation directives
    # @param file_name
    # @param [Hash] transform_directives - each key corresponds to a desired derivative.  Associated values vary according to processor being used.
    # @param [Hash] opts for specifying things like choice of :processor (processor defaults to :image)
    #
    # @example This will create content_thumb
    #   transform_file :content, { :thumb => "100x100>" }
    #
    # @example Specify the dsid for the output file
    #   transform_file :content, { :thumb => {size: "200x300>", datastream: 'thumbnail'} }
    #
    # @example Create multiple derivatives with one set of directives.  This will create content_thumb and content_medium
    #   transform_file :content, { :medium => "300x300>", :thumb => "100x100>" }
    #
    # @example Specify which processor you want to use (defaults to :image)
    #   transform_file :content, { :mp3 => {format: 'mp3'}, :ogg => {format: 'ogg'} }, processor: :audio
    #   transform_file :content, { :mp4 => {format: 'mp4'}, :webm => {format: 'webm'} }, processor: :video
    #
    def transform_file(file_name, transform_directives, opts={})
      processor = processor_class(opts[:processor] || :image)
      processor.new(self, file_name, transform_directives).process
    end

    def processor_class(processor)
      case processor
        when :video
          Hydra::Derivatives::Video::Processor
        else
          "Hydra::Derivatives::#{processor.to_s.classify}".constantize
        end
    end

    def transform_datastream(file_name, transform_directives, opts={})
      transform_file(file_name, transform_directives, opts={})
    end
    deprecation_deprecate :transform_datastream


    module ClassMethods
      # Register transformation schemes for generating derivatives.
      # You can do this using a block or by defining a callback method.
      #
      # @example Define transformation scheme using a block
      #    makes_derivatives do |obj|
      #      case obj.mime_type
      #      when 'application/pdf'
      #        obj.transform_file :content, { :thumb => "100x100>" }
      #      when 'audio/wav'
      #        obj.transform_file :content, { :mp3 => {format: 'mp3'}, :ogg => {format: 'ogg'} }, processor: :audio
      #
      # @example Define transformation scheme using a callback method
      #      makes_derivatives :generate_image_derivatives
      #
      #      def generate_image_derivatives
      #        case mime_type
      #        when 'image/png', 'image/jpg'
      #          transform_file :content, { :medium => "300x300>", :thumb => "100x100>" }
      #        end
      #      end
      def makes_derivatives(*callback_method_names, &block)
        self.transformation_schemes ||= []
        if block_given?
          self.transformation_schemes << block
        end
        callback_method_names.each do |callback_name|
          self.transformation_schemes << callback_name
        end
      end
    end
  end
end
