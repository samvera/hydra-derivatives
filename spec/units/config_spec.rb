require 'spec_helper'

describe "the configuration" do
  subject {Hydra::Derivatives }

  it "should have some configuration defaults" do
    subject.ffmpeg_path.should == 'ffmpeg'
    subject.enable_ffmpeg.should be_true
    subject.libreoffice_path.should == 'soffice'
    subject.temp_file_base.should == '/tmp'
    subject.fits_path.should == 'fits.sh'
  end

  it "should let you change the configuration" do
    subject.ffmpeg_path = '/usr/local/ffmpeg-1.0/bin/ffmpeg'
    subject.ffmpeg_path.should == '/usr/local/ffmpeg-1.0/bin/ffmpeg'
  end

  it "should let you reset the configuration" do
    subject.ffmpeg_path = '/usr/local/ffmpeg-1.0/bin/ffmpeg'
    subject.reset_config!
    subject.ffmpeg_path.should == 'ffmpeg'
  end

  describe "video codecs" do
    let(:default_codec) {Hydra::Derivatives::Config.new.video_codec}

    before do
      subject.reset_config!
    end
    it "lets you set one video codec without changing the others" do
      subject.video_codec = {jpg:"-vcodec abc123"}
      subject.video_codec[:jpg].should == "-vcodec abc123"
      subject.video_codec[:mp4].should == default_codec[:mp4]
      subject.video_codec[:webm].should == default_codec[:webm]
      subject.video_codec[:mvk].should == default_codec[:mvk]
    end
    it "lets you set a new video codec without changing the existing ones" do
      subject.video_codec = {abc:"-vcodec abc123"}
      subject.video_codec[:abc].should == "-vcodec abc123"
      subject.video_codec[:jpg].should == default_codec[:jpg]
      subject.video_codec[:mp4].should == default_codec[:mp4]
      subject.video_codec[:webm].should == default_codec[:webm]
      subject.video_codec[:mvk].should == default_codec[:mvk]
    end
  end
end
