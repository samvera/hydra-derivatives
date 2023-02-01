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
end
