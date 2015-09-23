require 'spec_helper'

describe Hydra::Derivatives::Processor do

  let(:object)        { "Fake Object"  }
  let(:source_name)   { 'content' }
  let(:directives)    { { thumb: "100x100>" } }

  subject { Hydra::Derivatives::Processor.new(object, source_name, directives)}

  describe "source_file" do
    it "relies on the source_file_service" do
      expect(subject.source_file_service).to receive(:call).with(object, source_name)
      subject.source_file
    end
  end

  describe "output_file_service" do
    let(:custom_output_file_service) { "fake service" }
    let(:another_custom_output_file_service) { "another fake service" }

    context "as a global configuration setting" do
      before do
        allow(Hydra::Derivatives).to receive(:output_file_service).and_return(custom_output_file_service)
      end
      it "utilizes the default output file service" do
        expect(subject.output_file_service).to eq(custom_output_file_service)
      end
    end

    context "as an instance level configuration setting" do
      subject { Hydra::Derivatives::Processor.new(object, source_name, directives, output_file_service: another_custom_output_file_service)}
      it "accepts a custom output file service as an option" do
        expect(subject.output_file_service).to eq(another_custom_output_file_service)
      end
    end
  end

  describe "source_file_service" do

    let(:custom_source_file_service) { "fake service" }
    let(:another_custom_source_file_service) { "another fake service" }

    context "as a global configuration setting" do
      before do
        allow(Hydra::Derivatives).to receive(:source_file_service).and_return(custom_source_file_service)
      end
      it "utilizes the default source file service" do
        expect(subject.source_file_service).to eq(custom_source_file_service)
      end
    end

    context "as an instance level configuration setting" do
      subject { Hydra::Derivatives::Processor.new(object, source_name, directives, source_file_service: another_custom_source_file_service)}
      it "accepts a custom source file service as an option" do
        expect(subject.source_file_service).to eq(another_custom_source_file_service)
      end
    end
  end

end
