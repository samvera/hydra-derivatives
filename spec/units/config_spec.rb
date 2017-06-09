require 'spec_helper'

describe "the configuration" do
  subject { Hydra::Derivatives::Config.new }

  before do
    # It's not always /tmp; it depends on OS and ENV vars
    allow(Dir).to receive(:tmpdir).and_return('/tmp')
  end

  it "has some configuration defaults" do
    expect(subject.ffmpeg_path).to eq('ffmpeg')
    expect(subject.enable_ffmpeg).to be true
    expect(subject.libreoffice_path).to eq('soffice')
    expect(subject.temp_file_base).to eq('/tmp')
    expect(subject.fits_path).to eq('fits.sh')
    expect(subject.kdu_compress_path).to eq('kdu_compress')
    expect(subject.output_file_service).to eq(Hydra::Derivatives::PersistBasicContainedOutputFileService)
    expect(subject.source_file_service).to eq(Hydra::Derivatives::RetrieveSourceFileService)
  end

  it "lets you change the configuration" do
    subject.ffmpeg_path = '/usr/local/ffmpeg-1.0/bin/ffmpeg'
    expect(subject.ffmpeg_path).to eq('/usr/local/ffmpeg-1.0/bin/ffmpeg')

    subject.kdu_compress_path = '/opt/local/bin/kdu_compress'
    expect(subject.kdu_compress_path).to eq('/opt/local/bin/kdu_compress')

    subject.enable_ffmpeg = false
    expect(subject.enable_ffmpeg).to be false
  end

  it "lets you set a custom output file service" do
    output_file_service = double("MyOutputFileService")
    subject.output_file_service = output_file_service
    expect(subject.output_file_service).to eq(output_file_service)
  end

  it "lets you set a custom source file service" do
    source_file_service = double("MyRetriveSourceFileService")
    subject.source_file_service = source_file_service
    expect(subject.source_file_service).to eq(source_file_service)
  end

  it "lets you set the poll time for ActiveEncode jobs" do
    expect(subject.active_encode_poll_time).to eq 10
    subject.active_encode_poll_time = 15
    expect(subject.active_encode_poll_time).to eq 15
  end
end
