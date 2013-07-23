require 'active_fedora'
require 'rmagick'
module Hydra
  module Derivatives
    extend ActiveSupport::Concern
    extend ActiveSupport::Autoload

    autoload :Processor
    autoload :Image
    autoload :Ffmpeg
    autoload :Video
    autoload :Audio
    autoload :ExtractMetadata

    attr_writer :ffmpeg_path, :temp_file_base, :fits_path
    def self.ffmpeg_path
      #Sufia.config.ffmpeg_path
      @ffmpeg_path ||= 'ffmpeg'
    end

    def self.temp_file_base
      #Sufia.config.temp_file_base
      @temp_file_base ||= '/tmp'
    end

    def self.fits_path
      #Sufia.config.fits_path
      @fits_path ||= 'fits.sh'
    end

    included do
      class_attribute :transformation_scheme
    end


    # Runs all of the transformations immediately.
    # You may want to run this job in the background as it may take a long time.
    def create_derivatives 
      transformation_scheme.each do |datastream, value|
        transform_datastream(datastream, value) if self.datastreams[datastream.to_s].has_content?
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
      # @option args [Symbol] :based_on the method that holds the differentiator column
      # @option args [String, Array] :when activates this set of derivatives when the the differentiator column is includes one of these. 
      # @option args [Hash] :derivatives the derivatives to be produced
      # @option args [Symbol, Array] :processors the processors to run to produce the derivatives 
      def initialize(args)
        self.differentiator = args[:based_on]
        self.selector = args[:when]
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
      # @option args [Symbol] :based_on the method that holds the differentiator column
      # @option args [String, Array] :when activates this set of derivatives when the the differentiator column is includes one of these. 
      # @option args [Hash] :derivatives the derivatives to be produced
      # @option args [Symbol, Array] :processors the processors to run to produce the derivatives 
      # @example
      #    makes_derivatives_of :content, based_on: :mime_type, when: 'text/pdf',
      #        derivatives: { :text => { :quality => :better }, processors: [:ocr]}
      #
      #    makes_derivatives_of :content, based_on: :mime_type, when: ['image/png', 'image/jpg'],
      #        derivatives: { :medium => "300x300>", :thumb => "100x100>" }
      def makes_derivatives_of(datastream, args = {})
        self.transformation_scheme ||= {}
        self.transformation_scheme[datastream.to_sym] ||= []
        self.transformation_scheme[datastream.to_sym] << TransformationDirective.new(args)
      end
    end
  end
end
