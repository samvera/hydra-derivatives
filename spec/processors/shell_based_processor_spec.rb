require 'spec_helper'

describe Hydra::Derivatives::Processors::ShellBasedProcessor do
  before do
    class TestProcessor
      include Hydra::Derivatives::Processors::ShellBasedProcessor
    end
  end

  after { Object.send(:remove_const, :TestProcessor) }

  let(:processor) { TestProcessor.new }

  describe "options_for" do
    it "returns a hash" do
      expect(processor.options_for("a")).to be_a Hash
    end
  end
end
