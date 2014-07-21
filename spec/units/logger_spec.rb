require 'spec_helper'

describe Hydra::Derivatives::Logger do

  context "with log levels" do

    let(:levels) { ["unknown", "fatal", "error", "warn", "info", "debug"] }

    it "should respond successfully" do
      levels.each do |level|
        expect(Hydra::Derivatives::Logger.respond_to?(level)).to be_truthy
      end
    end
    it "should accept messages" do
      expect(Hydra::Derivatives::Logger.warn("message")).to be_truthy
    end
  end

  context "with garbage" do
    it "should raise an error" do
      expect{Hydra::Derivatives::Logger.garbage}.to raise_error(NoMethodError)
    end
  end

end
