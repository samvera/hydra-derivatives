require 'spec_helper'

describe Hydra::Derivatives::Processors::ActiveEncode do

#  before do
#    ActiveEncode::Base.engine_adapter = :test
#  end

  let(:file_path) { File.join(fixture_path, 'videoshort.mp4') }
  let(:directives) { [] }
  let(:output_file_service) { Hydra::Derivatives::NullOutputFileService }
  let(:processor) { described_class.new(file_path, directives, output_file_service: output_file_service) }

  describe '#process' do
    subject { processor.process }

    let(:encode_double) { double('encode double', reload: self, state: state, errors: errors) }

    context 'when the encoding failed' do
      let(:state) { :failed }
      let(:errors) { ['error 1', 'error 2'] }

      before do
        allow(encode_double).to receive(:failed?).and_return(true)
        allow(::ActiveEncode::Base).to receive(:create).and_return(encode_double)
      end

      it 'raises an exception' do
        expect{ subject }.to raise_error('Encoding failed: error 1 ; error 2')
      end
    end
  end

end
