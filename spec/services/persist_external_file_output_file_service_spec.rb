require 'spec_helper'

describe Hydra::Derivatives::PersistExternalFileOutputFileService do
  before do
    class ExternalDerivativeContainerObject < ActiveFedora::Base
      has_subresource "external_derivative"
    end
  end
  after do
    Object.send(:remove_const, :ExternalDerivativeContainerObject)
  end

  let(:object)            { ExternalDerivativeContainerObject.create }
  let(:directives)        { { url: "#{object.uri}/external_derivative" } }
  let(:external_url)      { 'http://www.example.com/external/content' }
  let(:output)            { { url: external_url } }
  let(:destination_name)  { 'external_derivative' }

  describe '.call' do
    it "persists the external file to the specified destination on the given object" do
      described_class.call(output, directives)
      expect(object.send(destination_name.to_sym).mime_type).to eq "message/external-body;access-type=URL;url=\"http://www.example.com/external/content\""
      expect(object.send(destination_name.to_sym).content).to eq ''
    end
  end
end
