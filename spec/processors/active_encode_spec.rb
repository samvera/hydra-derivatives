require 'spec_helper'

describe Hydra::Derivatives::Processors::ActiveEncode do
  # before { # ActiveEncode::Base.engine_adapter = :test }

  let(:file_path) { File.join(fixture_path, 'videoshort.mp4') }
  let(:directives) { [] }
  let(:output_file_service) { Hydra::Derivatives::NullOutputFileService }
  let(:processor) { described_class.new(file_path, directives, output_file_service: output_file_service) }

  describe '#process' do
    subject { processor.process }

    # Mock out the actual encoding, just pretend that the
    # encode finished and returned a certain status.
    let(:failed_status) { false }
    let(:cancelled_status) { false }
    let(:errors) { [] }
    let(:encode_double) do
      double('encode double',
             reload: self, state: state, errors: errors,
             :failed? => failed_status,
             :cancelled? => cancelled_status)
    end

    context 'when the encoding failed' do
      let(:state) { :failed }
      let(:failed_status) { true }
      let(:errors) { ['error 1', 'error 2'] }

      before do
        allow(::ActiveEncode::Base).to receive(:create).and_return(encode_double)
      end

      it 'raises an exception' do
        expect { subject }.to raise_error("Encoding failed for #{file_path}: error 1 ; error 2")
      end
    end

    context 'when the encoding was cancelled' do
      let(:state) { :cancelled }
      let(:cancelled_status) { true }

      before do
        allow(::ActiveEncode::Base).to receive(:create).and_return(encode_double)
      end

      it 'raises an exception' do
        expect { subject }.to raise_error("Encoding cancelled for #{file_path}")
      end
    end
  end
end
