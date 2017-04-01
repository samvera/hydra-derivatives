require 'spec_helper'

describe Hydra::Derivatives::ActiveEncodeDerivatives do
  context '.create' do
    before do
      class TestVideo < ActiveFedora::Base
        attr_accessor :remote_file_name
      end
    end

    after { Object.send(:remove_const, :TestVideo) }

    let(:file_path) { 'some/path/to/my_video.mp4' }
    let(:video_record) { TestVideo.new(remote_file_name: file_path) }
    let(:options) { { source: :remote_file_name, outputs: [low_res_video] } }
    let(:low_res_video) { { some_key: 'some options to pass to my encoder service' } }
    let(:processor) { double('processor') }

    it 'calls the processor with the right arguments' do
      expect(Hydra::Derivatives::Processors::ActiveEncode).to receive(:new).with(file_path, low_res_video, output_file_service: Hydra::Derivatives::PersistExternalFileOutputFileService).and_return(processor)
      expect(processor).to receive(:process)
      described_class.create(video_record, options)
    end

    context 'with a custom encode class' do
      before { class TestEncode < ::ActiveEncode::Base; end }
      after { Object.send(:remove_const, :TestEncode) }

      let(:options) { { encode_class: TestEncode, source: :remote_file_name, outputs: [low_res_video] } }

      it 'calls the processor with the right arguments' do
        expect(Hydra::Derivatives::Processors::ActiveEncode).to receive(:new).with(file_path, low_res_video, output_file_service: Hydra::Derivatives::PersistExternalFileOutputFileService, encode_class: TestEncode).and_return(processor)
        expect(processor).to receive(:process)
        described_class.create(video_record, options)
      end
    end
  end
end
