require 'spec_helper'

describe Hydra::Derivatives::TempfileService do
  let(:class_with_metadata_extraction) do
    Class.new do
      attr_reader :content, :mime_type, :uri

      def initialize(options = {})
        @content = options.fetch(:content, '')
        @mime_uype = options.fetch(:mime_type, nil)
        @uri = 'http://example.com/pid/123'
      end

      def has_content?; content.present?; end
    end
  end

  let(:initialization_options) { { content: 'abc', mime_type: 'text/plain' } }

  let(:file) { class_with_metadata_extraction.new(initialization_options) }

  subject { Hydra::Derivatives::TempfileService.new(file) }
  context '#tempfile' do
    it 'has a method called to_tempfile' do
      expect { |b| subject.tempfile(&b) }.to yield_with_args(Tempfile)
    end
  end
end
