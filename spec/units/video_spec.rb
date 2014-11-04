require 'spec_helper'

describe Hydra::Derivatives::Video do
  describe "when arguments are passed as a hash" do
    describe "and datastream is provided as an argument" do
      let(:directives) {{ :thumb => {format: "webm", datastream: 'thumbnail'} }}
      subject { Hydra::Derivatives::Video.new(double(:obj), 'content', directives)}
      it "should create a datastream with the specified name" do
        expect(subject).to receive(:encode_file).with("thumbnail", "webm", 'video/webm', {Hydra::Derivatives::Ffmpeg::OUTPUT_OPTIONS =>"-s 320x240 -vcodec libvpx -acodec libvorbis -g 30 -b:v 345k -ac 2 -ab 96k -ar 44100", Hydra::Derivatives::Ffmpeg::INPUT_OPTIONS=>""})
        subject.process

      end
    end

    describe "and datastream is not provided as an argument" do
      let(:directives) {{ :thumb => {format: "webm"} }}
      subject { Hydra::Derivatives::Video.new(double(:obj), 'content', directives)}
      it "should create a datastream and infer the name" do
        expect(subject).to receive(:encode_file).with("content_thumb", "webm", 'video/webm', {Hydra::Derivatives::Ffmpeg::OUTPUT_OPTIONS =>"-s 320x240 -vcodec libvpx -acodec libvorbis -g 30 -b:v 345k -ac 2 -ab 96k -ar 44100", Hydra::Derivatives::Ffmpeg::INPUT_OPTIONS=>""})
        subject.process

      end
    end

    describe "and jpg is requested" do
      let(:directives) {{ :thumb => {:format => 'jpg' , datastream: 'thumbnail'} }}
      subject { Hydra::Derivatives::Video.new(double(:obj), 'content', directives)}
      it "should create a datastream and infer the name" do
        expect(subject).to receive(:encode_file).with("thumbnail", "jpg", "image/jpeg", {:output_options=>"-s 320x240 -vcodec mjpeg -vframes 1 -an -f rawvideo", :input_options=>" -itsoffset -2"})
        subject.process

      end
    end
  end
end

