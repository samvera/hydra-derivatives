require 'spec_helper'

module Hydra::Derivatives
  describe ExtractMetadata do
    let(:class_with_metadata_extraction) do
      Class.new do
        attr_reader :content, :mime_type, :uri

        def initialize(options = {})
          @content = options.fetch(:content, '')
          @mime_uype = options.fetch(:mime_type, nil)
          @uri = 'http://example.com/pid/123'
        end

        include Hydra::Derivatives::ExtractMetadata
        def has_content?; content.present?; end
      end
    end

    let(:initialization_options) { {content: 'abc', mime_type: 'text/plain'} }
    subject { class_with_metadata_extraction.new(initialization_options) }

    context '#extract_metadata' do
      context 'without content' do
        let(:initialization_options) { {content: '', mime_type: 'text/plain'} }
        it 'should be nil' do
          expect(subject.extract_metadata).to be_nil
        end
      end

      context 'with content', unless: ENV['TRAVIS'] == 'true' do
        let(:mime_type) { 'image/jpeg' }
        it 'should get some XML' do
          expect(subject.extract_metadata).to match "<identity format=\"Plain text\" mimetype=\"text/plain\""
        end
      end
    end
  end
end
