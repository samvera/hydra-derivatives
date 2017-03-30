require 'spec_helper'

describe Hydra::Derivatives::Processors::Image do
  let(:file_name) { "file_name" }
  subject { described_class.new(file_name, directives) }

  context "when arguments are passed as a hash" do
    before { allow(subject).to receive(:load_image_transformer).and_return(mock_image) }

    context "with a multi-page pdf source file" do
      let(:first_page)  { double("MockPage") }
      let(:second_page) { double("MockPage") }
      let(:mock_image)  { double("MockImageOfPdf", layers: [first_page, second_page]) }

      before { allow(mock_image).to receive(:type).and_return("PDF") }

      context "by default" do
        let(:directives) { { label: :thumb, size: "200x300>", format: 'png', quality: 75 } }

        it "uses the first page" do
          expect(first_page).to receive(:flatten)
          expect(second_page).not_to receive(:flatten)
          expect(first_page).to receive(:resize).with("200x300>")
          expect(second_page).not_to receive(:resize)
          expect(first_page).to receive(:format).with("png")
          expect(second_page).not_to receive(:format)
          expect(first_page).to receive(:quality).with("75")
          expect(second_page).not_to receive(:quality)
          expect(subject).to receive(:write_image).with(first_page)
          subject.process
        end
      end

      context "when specifying a layer" do
        let(:directives) { { label: :thumb, size: "200x300>", format: 'png', quality: 75, layer: 1 } }

        it "uses the second page" do
          expect(second_page).to receive(:flatten)
          expect(first_page).not_to receive(:flatten)
          expect(second_page).to receive(:resize).with("200x300>")
          expect(first_page).not_to receive(:resize)
          expect(second_page).to receive(:format).with("png")
          expect(first_page).not_to receive(:format)
          expect(second_page).to receive(:quality).with("75")
          expect(first_page).not_to receive(:quality)
          expect(subject).to receive(:write_image).with(second_page)
          subject.process
        end
      end
    end

    context "with an image source file" do
      before { allow(mock_image).to receive(:type).and_return("JPEG") }

      context "by default" do
        let(:mock_image) { double("MockImage") }
        let(:directives) { { label: :thumb, size: "200x300>", format: 'png', quality: 75 } }

        it "uses the image file" do
          expect(mock_image).not_to receive(:layers)
          expect(mock_image).to receive(:flatten)
          expect(mock_image).to receive(:resize).with("200x300>")
          expect(mock_image).to receive(:format).with("png")
          expect(mock_image).to receive(:quality).with("75")
          expect(subject).to receive(:write_image).with(mock_image)
          subject.process
        end
      end

      context "when specifying a layer" do
        let(:first_layer)  { double("MockPage") }
        let(:second_layer) { double("MockPage") }
        let(:mock_image)   { double("MockImage", layers: [first_layer, second_layer]) }
        let(:directives)   { { label: :thumb, size: "200x300>", format: 'png', quality: 75, layer: 1 } }

        it "uses the layer" do
          expect(second_layer).to receive(:flatten)
          expect(first_layer).not_to receive(:flatten)
          expect(second_layer).to receive(:resize).with("200x300>")
          expect(first_layer).not_to receive(:resize)
          expect(second_layer).to receive(:format).with("png")
          expect(first_layer).not_to receive(:format)
          expect(second_layer).to receive(:quality).with("75")
          expect(first_layer).not_to receive(:quality)
          expect(subject).to receive(:write_image).with(second_layer)
          subject.process
        end
      end
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

    context "when running the complete command", requires_imagemagick: true do
      let(:file_name) { File.join(fixture_path, "test.tif") }
      it "converts the image" do
        expect(Hydra::Derivatives::PersistBasicContainedOutputFileService).to receive(:call).with(kind_of(StringIO), directives)
        subject.process
      end
    end
  end
end
