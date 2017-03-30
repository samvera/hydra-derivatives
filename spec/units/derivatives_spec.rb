require 'spec_helper'

describe Hydra::Derivatives do
  before(:all) do
    class CustomFile < ActiveFedora::Base
      include Hydra::Derivatives
    end
  end

  after(:all) { Object.send(:remove_const, :CustomFile) }

  describe "source_file_service" do
    before  { subject.source_file_service = custom_source_file_service }

    context "as a global configuration setting" do
      let(:custom_source_file_service) { "fake service" }
      subject { CustomFile }

      it "utilizes the default source file service" do
        expect(subject.source_file_service).to eq(custom_source_file_service)
      end
    end

    context "as an instance level configuration setting" do
      let(:custom_source_file_service) { "another fake service" }
      subject { CustomFile.new }

      it "accepts a custom source file service as an option" do
        expect(subject.source_file_service).to eq(custom_source_file_service)
      end
    end
  end

  [:ffmpeg_path, :libreoffice_path, :temp_file_base, :fits_path, :kdu_compress_path,
   :kdu_compress_recipes, :enable_ffmpeg, :source_file_service, :output_file_service].each do |method|
    describe method.to_s do
      it 'returns the config value' do
        expect(subject.send(method)).to eq subject.config.send(method)
      end
    end
    describe "#{method}=" do
      it 'stores config changes' do
        expect { subject.send("#{method}=", "new_value") }.to change { subject.config.send(method) }.from(subject.config.send(method)).to("new_value")
      end
    end
  end

  describe 'reset_config!' do
    it "lets you reset the configuration" do
      subject.ffmpeg_path = '/usr/local/ffmpeg-1.0/bin/ffmpeg'
      subject.reset_config!
      expect(subject.ffmpeg_path).to eq('ffmpeg')

      subject.kdu_compress_path = '/usr/local/bin/kdu_compress'
      subject.reset_config!
      expect(subject.kdu_compress_path).to eq('kdu_compress')
    end
  end
end
