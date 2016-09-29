require 'spec_helper'

describe Hydra::Derivatives do
  before(:all) do
    class CustomFile < ActiveFedora::Base
      include Hydra::Derivatives
    end
  end

  after(:all) { Object.send(:remove_const, :CustomFile) }

  describe "source_file_service" do
    before  { subject.source_file_service = custom_source_file_service }

    context "as a global configuration setting" do
      let(:custom_source_file_service) { "fake service" }
      subject { CustomFile }

      it "utilizes the default source file service" do
        expect(subject.source_file_service).to eq(custom_source_file_service)
      end
    end

    context "as an instance level configuration setting" do
      let(:custom_source_file_service) { "another fake service" }
      subject { CustomFile.new }

      it "accepts a custom source file service as an option" do
        expect(subject.source_file_service).to eq(custom_source_file_service)
      end
    end
  end
end
