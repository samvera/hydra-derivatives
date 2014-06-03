require 'spec_helper'

describe "the configuration" do
  subject {Hydra::Derivatives }

  it "should have some configuration defaults" do
    expect(subject.ffmpeg_path).to eq('ffmpeg')
    expect(subject.enable_ffmpeg).to be true
    expect(subject.libreoffice_path).to eq('soffice')
    expect(subject.temp_file_base).to eq('/tmp')
    expect(subject.fits_path).to eq('fits.sh')
    expect(subject.kdu_compress_path).to eq('kdu_compress')
  end

  it "should let you change the configuration" do
    subject.ffmpeg_path = '/usr/local/ffmpeg-1.0/bin/ffmpeg'
    expect(subject.ffmpeg_path).to eq('/usr/local/ffmpeg-1.0/bin/ffmpeg')

    subject.kdu_compress_path = '/opt/local/bin/kdu_compress'
    expect(subject.kdu_compress_path).to eq('/opt/local/bin/kdu_compress')

  end

  it "should let you reset the configuration" do
    subject.ffmpeg_path = '/usr/local/ffmpeg-1.0/bin/ffmpeg'
    subject.reset_config!
    expect(subject.ffmpeg_path).to eq('ffmpeg')

    subject.kdu_compress_path = '/usr/local/bin/kdu_compress'
    subject.reset_config!
    expect(subject.kdu_compress_path).to eq('kdu_compress')
  end

end
