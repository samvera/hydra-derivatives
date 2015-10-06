require 'spec_helper'

describe Hydra::Derivatives::Processors::Image do
  let(:output_file) { double }
  let(:file_name) { double }

  subject { described_class.new(file_name, directives) }

  before { allow(subject).to receive(:output_file).with(file_name).and_return(output_file) }

  describe "when arguments are passed as a hash" do
    let(:directives) { { label: :thumb, size: "200x300>", format: 'png', quality: 75 } }
    let(:file_name) { 'thumbnail' }

    it "uses the specified size and name and quality" do
      expect(subject).to receive(:create_resized_image).with(file_name, "200x300>", 'png', 75)
      subject.process
    end
  end

  describe 'timeout' do
    let(:directives) { { thumb: "100x100>" } }
    let(:file_name) { 'content_thumb' }

    before do
      allow(subject).to receive(:create_resized_image).with("100x100>", 'png')
    end

    context 'when set' do
      before do
        subject.timeout = 0.1
        allow_any_instance_of(described_class).to receive(:process_without_timeout) { sleep 0.2 }
      end
      it 'raises a timeout exception' do
        expect { subject.process }.to raise_error Hydra::Derivatives::TimeoutError
      end
    end

    context 'when not set' do
      before { subject.timeout = nil }
      it 'processes without a timeout' do
        expect(subject).to receive(:process_with_timeout).never
        expect(subject).to receive(:process_without_timeout).once
        subject.process
      end
    end
  end
end
