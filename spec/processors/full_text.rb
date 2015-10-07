require 'spec_helper'

describe Hydra::Derivatives::Processors::FullText do
  let(:file_path) { File.join(fixture_path, 'test.docx') }
  let(:directives) { { format: 'txt', url: 'http://localhost:8983/fedora/rest/dev/1234/ogg' } }
  let(:processor) { described_class.new(file_path, directives) }

  describe "process" do
    subject { processor.process }

    context "when it is successful" do
      before do
        allow_any_instance_of(described_class).to receive(:fetch).and_return('{"":"one two three"}')
      end
      it { is_expected.to be true }
    end

    it 'extracts fulltext and stores the results' do
      expect(processor.output_file_service).to receive(:call).with(/Project Charter for E-Content Delivery Platform Review/, directives)
      processor.process
    end
  end

  describe "fetch" do
    subject { processor.send(:fetch) }
    let(:request) { double }
    let(:response_body) { 'returned by Solr' }
    let(:resp) { double(code: '200', body: response_body) }
    let(:uri) { URI('http://example.com:99/solr/update') }

    before do
      allow(processor).to receive(:uri).and_return(URI('http://example.com:99/solr/update'))
      allow(Net::HTTP).to receive(:new).with('example.com', 99).and_return(request)
    end

    context "that is successful" do
      let(:resp) { double(code: '200', body: response_body) }
      it "calls the extraction service" do
        expect(request).to receive(:post).with('http://example.com:99/solr/update', String, "Content-Type" => "application/vnd.openxmlformats-officedocument.wordprocessingml.document", "Content-Length" => "24244").and_return(resp)
        expect(subject).to eq response_body
      end
    end

    context "that fails" do
      let(:resp) { double(code: '500', body: response_body) }
      it "raises an error" do
        expect(request).to receive(:post).with('http://example.com:99/solr/update', String, "Content-Type" => "application/vnd.openxmlformats-officedocument.wordprocessingml.document", "Content-Length" => "24244").and_return(resp)
        expect { subject }.to raise_error RuntimeError, /Solr Extract service was unsuccessful. 'http:\/\/example\.com:99\/solr\/update' returned code 500 for .*spec\/fixtures\/test.docx\nreturned by Solr/
      end
    end
  end

  describe "uri" do
    subject { processor.send(:uri) }

    it "points at the extraction service" do
      expect(subject).to be_kind_of URI
      expect(subject.to_s).to end_with '/update/extract?extractOnly=true&wt=json&extractFormat=text'
    end
  end
end
