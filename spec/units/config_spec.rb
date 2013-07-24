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

end
