# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Hydra::Derivatives::Runner do
  describe ".processor_class" do
    it "raises an error if it's not overridden" do
      expect { described_class.processor_class }.to raise_error "Overide the processor_class method in a sub class"
    end
  end
end
