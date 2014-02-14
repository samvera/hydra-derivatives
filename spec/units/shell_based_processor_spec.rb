require 'spec_helper'


describe Hydra::Derivatives::ShellBasedProcessor do
  class TestProcessor  <
    include Hydra::Derivatives::ShellBasedProcessor
  end

  let (:processor) {TestProcessor.new}

  describe "has expected interface" do

    describe "options_for" do
      it "returns a hash" do
        expect(processor.options_for("a")).to be_a Hash
      end
    end
  end
end



