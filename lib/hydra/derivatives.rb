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
    autoload :ExtractMetadata

    def self.ffmpeg_path=(val)
      @ffmpeg_path = val
    end
    def self.ffmpeg_path
      #Sufia.config.ffmpeg_path
      @ffmpeg_path ||= 'ffmpeg'
    end

    def self.temp_file_base=(val)
      @temp_file_base = val
    end
    def self.temp_file_base
      #Sufia.config.temp_file_base
      @temp_file_base ||= '/tmp'
    end

    def self.fits_path=(val)
      @fits_path = val
    end
    def self.fits_path
      #Sufia.config.fits_path
      @fits_path ||= 'fits.sh'
    end

    def self.enable_ffmpeg=(val)
      @enable_ffmpeg = val
    end
    def self.enable_ffmpeg
      @enable_ffmpeg ||= true
    end

    included do
      class_attribute :transformation_scheme
    end


    # Runs all of the transformations immediately.
    # You may want to run this job in the background as it may take a long time.
    def create_derivatives 
      if transformation_scheme.present?
        transformation_scheme.each do |datastream_name, transform_blocks|
          datastream = self.datastreams[datastream_name.to_s]
          transform_blocks.each do |block| 
            block.call(self, datastream) if datastream.has_content? 
          end
        end
      else
        logger.warn "`create_derivatives' was called on an instance of #{self.class}, but no derivatives have been requested"
      end
    end

    # Transform a single datastream
    def transform_datastream(datastream, transform_parameters, opts={})
      processor = opts[:processor] ? opts[:processor] : :image
      "Hydra::Derivatives::#{processor.to_s.classify}".constantize.new(self, datastream.dsid, transform_parameters).process
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
      def makes_derivatives_of(datastream, &transform_block)
        self.transformation_scheme ||= {}
        self.transformation_scheme[datastream.to_sym] ||= []
        self.transformation_scheme[datastream.to_sym] << transform_block
      end
    end
  end
end
