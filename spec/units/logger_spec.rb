# frozen_string_literal: true
require 'spec_helper'

describe Hydra::Derivatives::Logger do
  context "with log levels" do
    let(:levels) { %w[unknown fatal error warn info debug] }

    it "responds successfully" do
      levels.each do |level|
        expect(described_class.respond_to?(level)).to be_truthy
      end
    end
    it "accepts messages" do
      expect(described_class.warn("message")).to be_truthy
    end
  end

  it "delegates respond_to_missing" do
    allow(ActiveFedora::Base.logger).to receive(:respond_to_missing?).with(:weird, false).and_return(true)
    expect(described_class.respond_to_missing?(:weird)).to be_truthy
  end

  context "with garbage" do
    it "raises an error" do
      expect { described_class.garbage }.to raise_error(NoMethodError)
    end
  end
end
