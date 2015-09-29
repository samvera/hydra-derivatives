require 'spec_helper'

describe Hydra::Derivatives::Processor do

  let(:object)        { "Fake Object"  }
  let(:source_name)   { 'content' }
  let(:directives)    { { thumb: "100x100>" } }
  let(:file_path)     { double }

  subject { Hydra::Derivatives::Processor.new(object, file_path, source_name, directives)}

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
      subject do
        Hydra::Derivatives::Processor.new(object, '/opt/derivatives/foo.mp4',
                                          source_name, directives,
                                          output_file_service: another_custom_output_file_service)
      end
      it "accepts a custom output file service as an option" do
        expect(subject.output_file_service).to eq(another_custom_output_file_service)
      end
    end
  end
end
