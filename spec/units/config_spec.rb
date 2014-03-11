require 'spec_helper'

describe "the configuration" do
  subject {Hydra::Derivatives }

  it "should have some configuration defaults" do
    subject.ffmpeg_path.should == 'ffmpeg'
    subject.enable_ffmpeg.should be_true
    subject.libreoffice_path.should == 'soffice'
    subject.temp_file_base.should == '/tmp'
    subject.fits_path.should == 'fits.sh'
    subject.kdu_compress_path.should == 'kdu_compress'
  end

  it "should let you change the configuration" do
    subject.ffmpeg_path = '/usr/local/ffmpeg-1.0/bin/ffmpeg'
    subject.ffmpeg_path.should == '/usr/local/ffmpeg-1.0/bin/ffmpeg'

    subject.kdu_compress_path = '/opt/local/bin/kdu_compress'
    subject.kdu_compress_path.should == '/opt/local/bin/kdu_compress'

  end

  it "should let you reset the configuration" do
    subject.ffmpeg_path = '/usr/local/ffmpeg-1.0/bin/ffmpeg'
    subject.reset_config!
    subject.ffmpeg_path.should == 'ffmpeg'

    subject.kdu_compress_path = '/usr/local/bin/kdu_compress'
    subject.reset_config!
    subject.kdu_compress_path.should == 'kdu_compress'
  end

end
