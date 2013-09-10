require "spec_helper"

class ExtractThing < ActiveFedora::Datastream
  include Hydra::Derivatives::ExtractMetadata
  attr_accessor :pid
end

describe Hydra::Derivatives::ExtractMetadata, :unless => $in_travis do
  let(:subject) { ExtractThing.new }
  let(:attachment) { File.open(File.expand_path('../../fixtures/world.png', __FILE__))}

  describe "Image Content" do
    it "should get a mime type" do
      subject.content = attachment
      subject.pid = "abc"
      xml = subject.extract_metadata
      doc = Nokogiri::HTML(xml)
      identity = doc.xpath('//identity').first
      identity.attr('mimetype').should == 'image/png'
    end
  end
end
