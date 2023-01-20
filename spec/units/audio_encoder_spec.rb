# frozen_string_literal: true
require 'spec_helper'

describe Hydra::Derivatives::AudioEncoder do
  before do
    @audio_encoder = described_class.new
  end

  describe 'fdk_aac?' do
    it 'outpus libfdk_aac if your ffmpeg was compiled with the library' do
      enable_libfdk_flags = '--enable-gpl --enable-version3 --enable-nonfree --enable-hardcoded-tables --enable-avresample --with-fdk-aac'
      @audio_encoder.instance_variable_set(:@ffmpeg_output, enable_libfdk_flags)
      audio_encoder = @audio_encoder.audio_encoder
      expect(audio_encoder).to eq('libfdk_aac')
    end

    it 'outputs aac if your ffmpeg was compiled with the library' do
      enable_libfdk_flags = '--enable-gpl --enable-version3 --enable-nonfree --enable-hardcoded-tables --enable-avresample'
      @audio_encoder.instance_variable_set(:@ffmpeg_output, enable_libfdk_flags)
      audio_encoder = @audio_encoder.audio_encoder
      expect(audio_encoder).to eq('aac')
    end
  end

  context "when ffmpeg is not installed" do
    it "logs a warning" do
      allow(ActiveFedora::Base.logger).to receive(:warn)
      allow(Open3).to receive(:capture3).with('ffmpeg -codecs').and_raise StandardError

      described_class.new

      expect(ActiveFedora::Base.logger).to have_received(:warn).with('Unable to find ffmpeg')
    end
  end
end
