require 'spec_helper'

describe Hydra::Derivatives::Processors::FullText do
  let(:file_path)  { File.join(fixture_path, 'test.docx') }
  let(:directives) { { format: 'txt', url: RDF::URI('http://localhost:8983/fedora/rest/dev/1234/ogg') } }
  let(:processor)  { described_class.new(file_path, directives) }

  describe "#process" do
    it 'extracts fulltext and stores the results' do
      expect(processor.output_file_service).to receive(:call) do |first, second|
        expect(first).to match(/Project Charter for E-Content Delivery Platform Review/)
        expect(second).to eq directives
      end
      processor.process
    end
  end

  describe "fetch" do
    let(:request)       { double }
    let(:response_body) { 'returned by Solr' }
    let(:uri)           { URI('http://example.com:99/solr/update') }

    subject { processor.send(:fetch) }

    before do
      allow(processor).to receive(:uri).and_return(uri)
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
        expect { subject }.to raise_error(RuntimeError, %r{^Solr Extract service was unsuccessful. 'http://example\.com:99/solr/update' returned code 500})
      end
    end
  end

  describe "uri" do
    subject { processor.send(:uri) }
    let(:root) { URI('http://example.com/solr/myCollection/') }

    before do
      allow(ActiveFedora::SolrService.instance.conn).to receive(:uri).and_return(root)
    end

    it "points at the extraction service" do
      expect(subject).to be_kind_of URI
      expect(subject.to_s).to eq 'http://example.com/solr/myCollection/update/extract?extractOnly=true&wt=json&extractFormat=text'
    end
  end
end
