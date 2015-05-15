require 'spec_helper'

describe Hydra::Derivatives do
  
  before(:all) do
    class CustomFile < ActiveFedora::Base
      include Hydra::Derivatives
    end
    class CustomProcessor < Hydra::Derivatives::Processor
    end
  end

  after(:all)  do
    Object.send(:remove_const, :CustomFile)
    Object.send(:remove_const, :CustomProcessor)
  end

  context "when using an included processor" do
    subject { CustomFile.new.processor_class(:image) }
    it { is_expected.to eql Hydra::Derivatives::Image }
  end

  context "when using the video processor" do
    subject { CustomFile.new.processor_class(:video) }
    it { is_expected.to eql Hydra::Derivatives::Video::Processor }
  end
  
  context "when using the video processor" do
    subject { CustomFile.new.processor_class("CustomProcessor") }
    it { is_expected.to eql CustomProcessor }
  end

  context "when using a fake processor" do
    it "raises an error" do
      expect( lambda{ CustomFile.new.processor_class("BogusProcessor") }).to raise_error(NameError)
    end
  end

end
