require 'spec_helper'

describe Hydra::Derivatives::Video do
  describe "when arguments are passed as a hash" do
    describe "and datastream is provided as an argument" do
      let(:directives) {{ :thumb => {format: "webm", datastream: 'thumbnail'} }}
      subject { Hydra::Derivatives::Video.new(double(:obj), 'content', directives)}
      it "should create a datastream with the specified name" do
        subject.should_receive(:encode_datastream).with("thumbnail", "webm", 'video/webm', "-s 320x240 -g 30 -b:v 345k -acodec libvorbis -ac 2 -ab 96k -ar 44100")
        subject.process

      end
    end

    describe "and datastream is not provided as an argument" do
      let(:directives) {{ :thumb => {format: "webm"} }}
      subject { Hydra::Derivatives::Video.new(double(:obj), 'content', directives)}
      it "should create a datastream and infer the name" do
        subject.should_receive(:encode_datastream).with("content_thumb", "webm", 'video/webm', "-s 320x240 -g 30 -b:v 345k -acodec libvorbis -ac 2 -ab 96k -ar 44100")
        subject.process

      end
    end
  end
end

