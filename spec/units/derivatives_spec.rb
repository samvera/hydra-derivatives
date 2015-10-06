require 'spec_helper'

describe Hydra::Derivatives do
  before(:all) do
    class CustomFile < ActiveFedora::Base
      include Hydra::Derivatives
    end
    class CustomProcessor < Hydra::Derivatives::Processors::Processor
    end
    class CustomSourceFileService
    end
    class CustomOutputFileService
    end
  end

  after(:all)  do
    Object.send(:remove_const, :CustomFile)
    Object.send(:remove_const, :CustomProcessor)
    Object.send(:remove_const, :CustomSourceFileService)
    Object.send(:remove_const, :CustomOutputFileService)
  end

  describe "source_file_service" do
    let(:custom_source_file_service) { "fake service" }
    before do
      allow(Hydra::Derivatives).to receive(:source_file_service).and_return(custom_source_file_service)
    end
    subject { Class.new { include Hydra::Derivatives } }

    context "as a global configuration setting" do
      it "utilizes the default source file service" do
        expect(subject.source_file_service).to eq(custom_source_file_service)
      end
    end

    context "as an instance level configuration setting" do
      let(:another_custom_source_file_service) { "another fake service" }
      subject { Class.new { include Hydra::Derivatives }.new }
      before { subject.source_file_service = another_custom_source_file_service }

      it "accepts a custom source file service as an option" do
        expect(subject.source_file_service).to eq(another_custom_source_file_service)
      end
    end
  end
end
