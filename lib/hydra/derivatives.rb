require 'active_fedora'
require 'RMagick'
module Hydra
  module Derivatives
    extend ActiveSupport::Concern
    extend ActiveSupport::Autoload

    autoload :Processor
    autoload :Image
    autoload :Ffmpeg
    autoload :Video
    autoload :Audio
    autoload :Config
    autoload :ExtractMetadata

    def self.config
      @config ||= reset_config!
    end

    def self.reset_config!
      @config = Config.new
    end

    [:ffmpeg_path, :libreoffice_path, :temp_file_base, :fits_path, :enable_ffmpeg].each do |method|
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
      class_attribute :transformation_scheme
    end


    # Runs all of the transformations immediately.
    # You may want to run this job in the background as it may take a long time.
    def create_derivatives 
      if transformation_scheme.present?
        transformation_scheme.each do |datastream, value|
          transform_datastream(datastream, value) if self.datastreams[datastream.to_s].has_content?
        end
      else
        logger.warn "`create_derivatives' was called on an instance of #{self.class}, but no derivatives have been requested"
      end
    end

    # Transform a single datastream
    def transform_datastream(datastream, directive_list)
      directive_list.each do |directive|
        if directive.applies?(self)
          processor = directive.processors ? Array(directive.processors).first : :image
          "Hydra::Derivatives::#{processor.to_s.classify}".constantize.new(self, datastream, directive.derivatives).process
        end
      end

    end

    class TransformationDirective
      attr_accessor :differentiator, :selector, :derivatives, :processors
      # @param [Hash] args the options 
      # @option args [Symbol] :when the method that holds the differentiator column
      # @option args [String, Array] :is_one_of activates this set of derivatives when the the differentiator column is includes one of these. 
      # @option args [String, Array] :is alias for :is_one_of 
      # @option args [Hash] :derivatives the derivatives to be produced
      # @option args [Symbol, Array] :processors the processors to run to produce the derivatives 
      def initialize(args)
        self.differentiator = args[:when]
        self.selector = args[:is_one_of] || args[:is]
        self.derivatives = args[:derivatives]
        self.processors = args[:processors]
      end

      def applies?(object)
        selector.include?(object.send(differentiator))
      end
    end

    module ClassMethods
      # @param [Symbol, String] datastream the datastream to operate on
      # @param [Hash] args the options 
      # @option args [Symbol] :when the method that holds the differentiator column
      # @option args [String, Array] :is_one_of activates this set of derivatives when the the differentiator column is includes one of these. 
      # @option args [String, Array] :is alias for :is_one_of 
      # @option args [Hash] :derivatives the derivatives to be produced
      # @option args [Symbol, Array] :processors the processors to run to produce the derivatives 
      # @example
      #    makes_derivatives_of :content, when: :mime_type, is: 'text/pdf',
      #        derivatives: { :text => { :quality => :better }, processors: [:ocr]}
      #
      #    makes_derivatives_of :content, when: :mime_type, is_one_of: ['image/png', 'image/jpg'],
      #        derivatives: { :medium => "300x300>", :thumb => "100x100>" }
      def makes_derivatives_of(datastream, args = {})
        self.transformation_scheme ||= {}
        self.transformation_scheme[datastream.to_sym] ||= []
        self.transformation_scheme[datastream.to_sym] << TransformationDirective.new(args)
      end
    end
  end
end
