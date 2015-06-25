require 'spec_helper'

describe Hydra::Derivatives::PersistBasicContainedOutputFileService do

  before(:all) do
    class BasicContainerObject < ActiveFedora::Base
      contains "the_derivative_name"
    end
  end

  let(:object)            { BasicContainerObject.new  }
  let(:file_path)         { File.join(fixture_path, 'test.tif') }
  let(:file)              { File.new(file_path)}
  let(:destination_name)  { 'the_derivative_name' }

  context "when file is basic contained (default assumption)" do  # alas, we have to support this as the default because all legacy code (and fedora 3 systems) created basic contained files
    let(:object)          { BasicContainerObject.new  }
    it "persists the file to the specified destination on the given object" do
      described_class.call(object, "fake file content", destination_name)
      expect(object.send(destination_name.to_sym).content).to eq("fake file content")
      expect(object.send(destination_name.to_sym).content_changed?).to eq false
    end
  end

end