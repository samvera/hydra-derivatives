require 'spec_helper'

describe "Transcoder" do
  before do
    class GenericFile < ActiveFedora::Base
      include Hydra::Derivatives
      has_metadata 'characterization', type: ActiveFedora::SimpleDatastream do |m|
          m.field "mime_type", :string
      end

      delegate :mime_type, :to => :characterization, :unique => true
      has_file_datastream 'content'

      makes_derivatives_of :content, based_on: :mime_type, when: 'text/pdf',
            derivatives: { :text => { :quality => :better }, processors: [:ocr]}

      makes_derivatives_of :content, based_on: :mime_type, when: ['image/png', 'image/jpg'],
             derivatives: { :medium => "300x300>", :thumb => "100x100>" }
      
    end
  end
  describe "with an attached image" do
    let(:attachment) { File.open(File.expand_path('../../fixtures/world.png', __FILE__))}
    let(:file) { GenericFile.new(mime_type: 'image/png').tap { |t| t.content.content = attachment; t.save } }

    it "should transcode" do
      file.datastreams.key?('content_medium').should be_false
      file.create_derivatives
      file.datastreams.key?('content_medium').should be_true 
      file.datastreams.key?('content_thumb').should be_true 
      file.datastreams.key?('content_text').should be_false 
    end
  end

end
