# frozen_string_literal: true
require 'spec_helper'

describe Hydra::Derivatives::Processors::ShellBasedProcessor do
  before do
    class TestProcessor
      include Hydra::Derivatives::Processors::ShellBasedProcessor
    end
  end

  after { Object.send(:remove_const, :TestProcessor) }

  let(:processor) { TestProcessor.new }
  let(:proc_class) { TestProcessor }

  describe "options_for" do
    it "returns a hash" do
      expect(processor.options_for("a")).to be_a Hash
    end
  end

  describe ".execute" do
    context "when an EOF error occurs" do
      it "doesn't crash" do
        proc_class.execute("echo foo")
      end
    end
  end

  context "when a IO::EAGAINWaitReadable error occurs" do
    before do
      expect(TestProcessor).to receive(:popen3).and_wrap_original do |m, *args|
        ret = m.call(*args)
        expect(ret[2]).to receive(:read_nonblock).and_invoke(->(_) { raise IO::EAGAINWaitReadable }, ->(_) { 'foobar' })
        allow(ret[2]).to receive(:eof).and_return(true)
        ret
      end
    end

    it "tries to retry" do
      proc_class.execute("echo foo")
    end
  end
end
