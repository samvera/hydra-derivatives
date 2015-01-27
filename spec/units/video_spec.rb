require 'spec_helper'

describe Hydra::Derivatives::Video::Processor do
  subject { described_class.new(double(:obj), 'content', directives)}

  describe ".config" do
    before do
      @original_config = described_class.config.dup
      described_class.config.mpeg4.codec = "-vcodec mpeg4 -acodec aac -strict -2"
    end

    after { described_class.config = @original_config }
      let(:directives) {{ thumb: { format: "mp4", datastream: 'thumbnail' } }}

    it "should be configurable" do
      expect(subject).to receive(:encode_file).with("thumbnail", "mp4", 'video/mp4', {Hydra::Derivatives::Ffmpeg::OUTPUT_OPTIONS =>"-s 320x240 -vcodec mpeg4 -acodec aac -strict -2 -g 30 -b:v 345k -ac 2 -ab 96k -ar 44100", Hydra::Derivatives::Ffmpeg::INPUT_OPTIONS=>""})
      subject.process
    end
  end

  context "when arguments are passed as a hash" do
    context "and datastream is provided as an argument" do
      let(:directives) {{ thumb: { format: "webm", datastream: 'thumbnail' } }}
      it "should create a datastream with the specified name" do
        expect(subject).to receive(:encode_file).with("thumbnail", "webm", 'video/webm', {Hydra::Derivatives::Ffmpeg::OUTPUT_OPTIONS =>"-s 320x240 -vcodec libvpx -acodec libvorbis -g 30 -b:v 345k -ac 2 -ab 96k -ar 44100", Hydra::Derivatives::Ffmpeg::INPUT_OPTIONS=>""})
        subject.process

      end
    end

    context "and datastream is not provided as an argument" do
      let(:directives) {{ thumb: { format: "webm" } }}
      it "should create a datastream and infer the name" do
        expect(subject).to receive(:encode_file).with("content_thumb", "webm", 'video/webm', {Hydra::Derivatives::Ffmpeg::OUTPUT_OPTIONS =>"-s 320x240 -vcodec libvpx -acodec libvorbis -g 30 -b:v 345k -ac 2 -ab 96k -ar 44100", Hydra::Derivatives::Ffmpeg::INPUT_OPTIONS=>""})
        subject.process

      end
    end

    context "and jpg is requested" do
      let(:directives) {{ thumb: { format: 'jpg' , datastream: 'thumbnail'} }}
      it "should create a datastream and infer the name" do
        expect(subject).to receive(:encode_file).with("thumbnail", "jpg", "image/jpeg", {:output_options=>"-s 320x240 -vcodec mjpeg -vframes 1 -an -f rawvideo", :input_options=>" -itsoffset -2"})
        subject.process

      end
    end
  end
end

