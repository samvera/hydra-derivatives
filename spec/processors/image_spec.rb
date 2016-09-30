require 'spec_helper'

describe Hydra::Derivatives::Processors::Image do
  let(:file_name) { "file_name" }
  subject { described_class.new(file_name, directives) }

  context "when arguments are passed as a hash" do
    let(:directives)       { { label: :thumb, size: "200x300>", format: 'png', quality: 75 } }
    let(:mock_transformer) { double("MockTransformer") }

    before do
      allow(subject).to receive(:load_image_transformer).and_return(mock_transformer)
      allow(subject).to receive(:write_image).with(mock_transformer)
    end

    it "uses the specified size and name and quality" do
      expect(mock_transformer).to receive(:flatten)
      expect(mock_transformer).to receive(:resize).with("200x300>")
      expect(mock_transformer).to receive(:format).with("png")
      expect(mock_transformer).to receive(:quality).with("75")
      subject.process
    end
  end

  describe "#process" do
    let(:directives) { { size: "100x100>", format: "png" } }

    context "when a timeout is set" do
      before do
        subject.timeout = 0.1
        allow(subject).to receive(:create_resized_image) { sleep 0.2 }
      end
      it "raises a timeout exception" do
        expect { subject.process }.to raise_error Hydra::Derivatives::TimeoutError
      end
    end

    context "when not set" do
      before { subject.timeout = nil }
      it "processes without a timeout" do
        expect(subject).to receive(:process_with_timeout).never
        expect(subject).to receive(:create_resized_image).once
        subject.process
      end
    end

    context "when running the complete command", unless: in_travis? do
      let(:file_name) { File.join(fixture_path, "test.tif") }
      it "converts the image" do
        expect(Hydra::Derivatives::PersistBasicContainedOutputFileService).to receive(:call).with(kind_of(StringIO), directives)
        subject.process
      end
    end
  end
end
