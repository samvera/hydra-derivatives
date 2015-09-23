require 'spec_helper'

describe Hydra::Derivatives do
  
  before(:all) do
    class CustomFile < ActiveFedora::Base
      include Hydra::Derivatives
    end
    class CustomProcessor < Hydra::Derivatives::Processor
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

  describe "initialize_processor" do
    subject{ CustomFile.new.send(:initialize_processor, :content, { thumb: '100x100>' }, processor: Hydra::Derivatives::Video::Processor, source_file_service: CustomSourceFileService, output_file_service: CustomOutputFileService) }
    it "passes source_file_service and output_file_service options to the processor" do
      expect(subject.class).to eq(Hydra::Derivatives::Video::Processor)
      expect(subject.source_file_service).to eq(CustomSourceFileService)
      expect(subject.output_file_service).to eq(CustomOutputFileService)
    end
  end

  context "when using an included processor" do
    subject { CustomFile.new.processor_class(:image) }
    it { is_expected.to eql Hydra::Derivatives::Image }
  end

  context "when using the video processor" do
    subject { CustomFile.new.processor_class(:video) }
    it { is_expected.to eql Hydra::Derivatives::Video::Processor }
  end
  
  context "when using the video processor" do
    subject { CustomFile.new.processor_class("CustomProcessor") }
    it { is_expected.to eql CustomProcessor }
  end

  context "when using a fake processor" do
    it "raises an error" do
      expect( lambda{ CustomFile.new.processor_class("BogusProcessor") }).to raise_error(NameError)
    end
  end

end
