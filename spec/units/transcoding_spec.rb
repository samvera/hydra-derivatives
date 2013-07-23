require 'spec_helper'

describe "Transcoder" do
  before do
    class ContentDatastream < ActiveFedora::Datastream
      include Hydra::Derivatives::ExtractMetadata
    end
    class GenericFile < ActiveFedora::Base
      include Hydra::Derivatives
      has_metadata 'characterization', type: ActiveFedora::SimpleDatastream do |m|
          m.field "mime_type", :string
      end

      delegate :mime_type, :to => :characterization, :unique => true
      has_file_datastream 'content', type: ContentDatastream

      makes_derivatives_of :content, based_on: :mime_type, when: 'text/pdf',
            derivatives: { :text => { :quality => :better }}, processors: [:ocr]

      makes_derivatives_of :content, based_on: :mime_type, when: 'audio/wav',
            derivatives: { :mp3 => {format: 'mp3'}, :ogg => {format: 'ogg'} }, processors: :audio

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
      file.datastreams['content_medium'].should have_content
      file.datastreams['content_medium'].mimeType.should == 'image/png'
      file.datastreams['content_thumb'].should have_content 
      file.datastreams['content_thumb'].mimeType.should == 'image/png'
      file.datastreams.key?('content_text').should be_false 
    end
  end

  describe "with an attached audio" do
    let(:attachment) { File.open(File.expand_path('../../fixtures/piano_note.wav', __FILE__))}
    let(:file) { GenericFile.new(mime_type: 'audio/wav').tap { |t| t.content.content = attachment; t.save } }

    it "should transcode" do
      file.create_derivatives
      file.datastreams['content_mp3'].should have_content
      file.datastreams['content_mp3'].mimeType.should == 'audio/mpeg'
      file.datastreams['content_ogg'].should have_content 
      file.datastreams['content_ogg'].mimeType.should == 'audio/ogg'
    end
  end

end
