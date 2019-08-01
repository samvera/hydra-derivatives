require 'spec_helper'

RSpec.describe Hydra::Derivatives::PersistOutputFileService do
  let(:original_filename_class) do
    Class.new do
      def original_filename
        "original filename"
      end

      def mime_type
        "image/tiff"
      end
    end
  end

  describe ".call" do
    it "raises an error if not implemented" do
      expect { described_class.call(nil, nil) }.to raise_error NotImplementedError, "PersistOutputFileService is an abstract class. Implement `call' on Class"
    end
  end

  describe ".determine_original_name" do
    context "when given something with an original filename" do
      it "returns it from that file" do
        expect(described_class.determine_original_name(original_filename_class.new)).to eq "original filename"
      end
    end
    context "when given something without an original filename" do
      it "returns derivative" do
        expect(described_class.determine_original_name("tardis")).to eq "derivative"
      end
    end
  end

  describe ".determine_mime_type" do
    context "when given something with #mime_type" do
      it "returns it from that file" do
        expect(described_class.determine_mime_type(original_filename_class.new)).to eq "image/tiff"
      end
    end
    context "when given something without #mime_type" do
      it "returns application/octet-stream" do
        expect(described_class.determine_mime_type("tardis")).to eq "application/octet-stream"
      end
    end
  end
end
