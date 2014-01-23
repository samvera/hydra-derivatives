require 'spec_helper'

describe Hydra::Derivatives::VideoStill do
  describe "when arguments are passed as a hash" do
    describe "and datastream is provided as an argument" do
      let(:directives) {{ :thumb => {format: "jpeg", datastream: 'thumbnail'} }}
      subject { Hydra::Derivatives::VideoStill.new(double(:obj), 'content', directives)}
      it "should create a datastream with the specified name" do
        subject.should_receive(:encode_datastream).with("thumbnail", "jpeg", 'image/jpeg', {:custom=>"-ss 5 -s 320x240 -vframes 1 -f image2"})
        subject.process
      end
    end

    describe "and datastream is not provided as an argument" do
      let(:directives) {{ :thumb => {format: "jpeg"} }}
      subject { Hydra::Derivatives::VideoStill.new(double(:obj), 'content', directives)}
      it "should create a datastream and infer the name" do
        subject.should_receive(:encode_datastream).with("content_thumb", "jpeg", 'image/jpeg', {:custom=>"-ss 5 -s 320x240 -vframes 1 -f image2"})
        subject.process
      end
    end

    describe "and ffmpeg options are provided as a hash" do
      let(:directives) {{ :thumb => {format: "jpeg", resolution: '640x480', seek_time: 10} }}
      subject { Hydra::Derivatives::VideoStill.new(double(:obj), 'content', directives)}
      it "should create a datastream and infer the name" do
        subject.should_receive(:encode_datastream).with("content_thumb", "jpeg", 'image/jpeg', {resolution: '640x480', seek_time: 10})
        subject.process
      end
    end
  end
end

