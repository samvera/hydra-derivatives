require 'spec_helper'

module Hydra::Derivatives
  describe ExtractMetadata do
    let(:class_with_metadata_extraction) {
      Class.new do
        attr_reader :content, :mimeType, :pid, :dsVersionID
        def initialize(options = {})
          @content = options.fetch(:content, '')
          @mimeType = options.fetch(:mime_type, nil)
          @pid = options.fetch(:pid, 'pid-123')
          @dsVersionID = options.fetch(:dsVersionID, 'version-id-1')
        end
        include Hydra::Derivatives::ExtractMetadata
        def has_content?; content.present?; end
      end
    }
    let(:initialization_options) { {content: 'abc', mime_type: 'text/plain'} }
    subject { class_with_metadata_extraction.new(initialization_options) }

    context '#extract_metadata' do
      context 'without content' do
        let(:initialization_options) { {content: '', mime_type: 'text/plain'} }
        its(:extract_metadata) { should be_nil}
      end

      context 'with content', unless: ENV['TRAVIS'] == 'true' do
        let(:mime_type) { 'image/jpeg' }
        its(:extract_metadata) { should match("<identity format=\"Plain text\" mimetype=\"text/plain\"")}
      end
    end
  end
end