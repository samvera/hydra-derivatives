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
    let(:completed_status) { false }
    let(:state) { :completed }
    let(:errors) { [] }
    let(:encode_double) do
      enc = double('encode', state: state, errors: errors,
                   'running?': false,
                   'completed?': completed_status,
                   'failed?': failed_status,
                   'cancelled?': cancelled_status)
      allow(enc).to receive(:reload).and_return(enc)
      enc
    end

    context 'when the encoding failed' do
      let(:state) { :failed }
      let(:failed_status) { true }
      let(:errors) { ['error 1', 'error 2'] }

      before do
        # Don't really encode the file during specs
        allow(::ActiveEncode::Base).to receive(:create).and_return(encode_double)
      end

      it 'raises an exception' do
        expect { subject }.to raise_error(Hydra::Derivatives::Processors::ActiveEncodeError, "ActiveEncode status was \"failed\" for #{file_path}: error 1 ; error 2")
      end
    end

    context 'when the encoding was cancelled' do
      let(:state) { :cancelled }
      let(:cancelled_status) { true }

      before do
        # Don't really encode the file during specs
        allow(::ActiveEncode::Base).to receive(:create).and_return(encode_double)
      end

      it 'raises an exception' do
        expect { subject }.to raise_error(Hydra::Derivatives::Processors::ActiveEncodeError, "ActiveEncode status was \"cancelled\" for #{file_path}")
      end
    end

    context 'when the timeout is set' do
      before do
        processor.timeout = 0.01
        allow(processor).to receive(:wait_for_encode) { sleep 0.1 }
      end

      it 'raises a timeout exception' do
        msg = "Unable to process ActiveEncode derivative: The command took longer than 0.01 seconds to execute. Encoding will be cancelled."
        expect { processor.process }.to raise_error Hydra::Derivatives::TimeoutError, msg
      end
    end

    context 'when the timeout is not set' do
      before { processor.timeout = nil }

      it 'processes the encoding without a timeout' do
        expect(processor).to receive(:wait_for_encode_with_timeout).never
        expect(processor).to receive(:wait_for_encode).once
        processor.process
      end
    end

    context 'when error occurs during timeout cleanup' do
      let(:error) { StandardError.new('some error message') }

      before do
        processor.timeout = 0.01
        allow(processor).to receive(:wait_for_encode) { sleep 0.1 }
        allow(::ActiveEncode::Base).to receive(:create).and_return(encode_double)
        allow(encode_double).to receive(:cancel!).and_raise(error)
      end

      it 'doesnt lose the timeout error, but adds the new error message' do
        msg = "Unable to process ActiveEncode derivative: The command took longer than 0.01 seconds to execute. Encoding will be cancelled. An error occurred while trying to cancel encoding: some error message"
        expect { processor.process }.to raise_error Hydra::Derivatives::TimeoutError, msg
      end
    end
  end
end
