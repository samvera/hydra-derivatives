require 'spec_helper'

describe Hydra::Derivatives::Processors::Processor do
  subject { described_class.new(file_path, directives) }

  let(:object)        { "Fake Object" }
  let(:source_name)   { 'content' }
  let(:directives)    { { thumb: "100x100>" } }
  let(:file_path)     { Pathname.new("test/unicorn.jpg") }

  describe "output_file_service" do
    let(:custom_output_file_service) { "fake service" }
    let(:another_custom_output_file_service) { "another fake service" }

    context "with a global configuration setting" do
      before do
        allow(Hydra::Derivatives).to receive(:output_file_service).and_return(custom_output_file_service)
      end
      it "utilizes the default output file service" do
        expect(subject.output_file_service).to eq(custom_output_file_service)
      end
    end

    context "with an instance level configuration setting" do
      subject do
        described_class.new('/opt/derivatives/foo.mp4', directives,
                            output_file_service: another_custom_output_file_service)
      end

      it "accepts a custom output file service as an option" do
        expect(subject.output_file_service).to eq(another_custom_output_file_service)
      end
    end
  end

  describe "#process" do
    it "raises an implementation error" do
      expect { subject.process }.to raise_error "Processor is an abstract class. Implement `process' on Hydra::Derivatives::Processors::Processor"
    end
  end

  describe "#output_file" do
    it "raises an implementation error" do
      expect { subject.output_file }.to raise_error "Processor is an abstract class. Utilize an implementation of a PersistOutputFileService class in Hydra::Derivatives::Processors::Processor"
    end
  end

  describe "#output_filename_for" do
    it "returns the basename of the source file" do
      expect(subject.output_filename_for("ignored")).to eq "unicorn.jpg"
    end
  end
end
