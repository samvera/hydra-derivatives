require 'spec_helper'
require 'stringio'

describe Hydra::Derivatives::IoDecorator do
  let(:file) { StringIO.new('hello') }

  context "one argument" do
    let(:decorator) { described_class.new(file) }
    describe "#read" do
      subject { decorator.read }
      it { is_expected.to eq 'hello' }
    end
  end

  context "three arguments" do
    let(:decorator) { described_class.new(file, 'text/plain', 'help.txt') }

    describe "#read" do
      subject { decorator.read }
      it { is_expected.to eq 'hello' }
    end

    describe "mime_type" do
      subject { decorator.mime_type }
      it { is_expected.to eq 'text/plain' }
    end

    describe "original_filename" do
      subject { decorator.original_filename }
      it { is_expected.to eq 'help.txt' }
    end

    describe "original_name" do
      subject { decorator.original_name }
      before { allow(Deprecation).to receive(:warn) }
      it { is_expected.to eq 'help.txt' }
    end
  end
end
