require 'spec_helper'

describe Hydra::Derivatives::PersistBasicContainedOutputFileService do
  before(:all) do
    class BasicContainerObject < ActiveFedora::Base
      has_subresource "the_derivative_name"
    end
  end

  let(:object)            { BasicContainerObject.new }
  let(:file_path)         { File.join(fixture_path, 'test.tif') }
  let(:file)              { File.new(file_path) }
  let(:destination_name)  { 'the_derivative_name' }

  # alas, we have to support this as the default because all legacy code (and fedora 3 systems) created basic contained files
  # The new signature does not have a destination_name option.  There is a default string that will get applied, but his might
  # not be sufficient.
  context "when file is basic contained (default assumption)" do
    let(:object) { BasicContainerObject.create }
    let(:content) { StringIO.new("fake file content") }
    let(:resource) { object.public_send(destination_name.to_sym) }
    context "and the content is a stream" do
      it "persists the file to the specified destination on the given object" do
        described_class.call(content, format: 'jpg', url: "#{object.uri}/the_derivative_name")
        expect(resource.content).to start_with("fake file content")
        expect(resource.content_changed?).to eq false
        expect(resource.mime_type).to eq 'image/jpeg'
      end
    end

    context "and content is a string" do
      let(:content) { "fake file content - ÅÄÖ" }
      it "persists the file to the specified destination on the given object" do
        described_class.call(content, format: 'txt', url: "#{object.uri}/the_derivative_name")
        expect(resource.content).to eq("fake file content - ÅÄÖ")
        expect(resource.mime_type).to eq 'text/plain;charset=UTF-8'
      end
    end
  end
end
