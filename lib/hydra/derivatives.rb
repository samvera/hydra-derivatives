require 'active_fedora'
require 'rmagick'
module Hydra
  module Derivatives
    extend ActiveSupport::Concern
    extend ActiveSupport::Autoload

    autoload :Processor
    autoload :Image

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
    def transform_datastream(datastream, directive)
      processor = directive.processors ? directive.processors.first : :image
      "Hydra::Derivatives::#{processor.to_s.classify}".constantize.new(self, datastream, directive.derivatives).process

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
        self.transformation_scheme[datastream.to_sym] = TransformationDirective.new(args)
      end
    end
  end
end
