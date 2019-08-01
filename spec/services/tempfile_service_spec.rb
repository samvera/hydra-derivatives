require 'spec_helper'

describe Hydra::Derivatives::TempfileService do
  subject { described_class.new(file) }

  let(:class_with_metadata_extraction) do
    Class.new do
      attr_reader :content, :mime_type, :uri

      def initialize(options = {})
        @content = options.fetch(:content, '')
        @mime_uype = options.fetch(:mime_type, nil)
        @uri = 'http://example.com/pid/123'
      end

      def has_content?
        content.present?
      end
    end
  end

  let(:class_with_tempfile) do
    Class.new do
      def to_tempfile
        "stub"
      end
    end
  end

  let(:initialization_options) { { content: 'abc', mime_type: 'text/plain' } }

  let(:file) { class_with_metadata_extraction.new(initialization_options) }

  describe '#tempfile' do
    it 'has a method called to_tempfile' do
      expect { |b| subject.tempfile(&b) }.to yield_with_args(Tempfile)
    end
    it "will call read on passed content if available" do
      file_with_readable_content = class_with_metadata_extraction.new(content: StringIO.new("test"), mime_type: 'text/plain')

      service = described_class.new(file_with_readable_content)

      service.tempfile do |t|
        expect(t.read).to eq "test"
      end
    end
    it "delegates down to `to_tempfile` if available" do
      tempfile_stub = class_with_tempfile.new
      service = described_class.new(tempfile_stub)

      expect(service.tempfile).to eq "stub"
    end
  end
end
