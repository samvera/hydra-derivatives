require 'spec_helper'

describe "Transcoder" do
  before(:all) do
    class ContentDatastream < ActiveFedora::Datastream
      include Hydra::Derivatives::ExtractMetadata
    end

    class GenericFile < ActiveFedora::Base
      include Hydra::Derivatives
      has_metadata 'characterization', type: ActiveFedora::SimpleDatastream do |m|
        m.field "mime_type", :string
      end

      has_attributes :mime_type, datastream: :characterization, multiple: false
      has_file_datastream 'content', type: ContentDatastream

      makes_derivatives do |obj|
        case obj.mime_type
        when 'application/pdf'
          obj.transform_datastream :content, { thumb: '100x100>' }
        when 'audio/wav'
          obj.transform_datastream :content, { mp3: { format: 'mp3' }, ogg: { format: 'ogg'} }, processor: :audio
        when 'video/avi'
          obj.transform_datastream :content, { mp4: { format: 'mp4' }, webm: { format: 'webm'}, thumbnail: { format: 'jpg', datastream: 'thumbnail' } }, processor: :video
        when 'image/png', 'image/jpg'
          obj.transform_datastream :content, { medium: "300x300>", thumb: "100x100>", access: { format: 'jpg', datastream: 'access'} }
        when 'application/vnd.ms-powerpoint'
          obj.transform_datastream :content, { preservation: { format: 'pptx'}, access: { format: 'pdf' }, thumbnail: { format: 'jpg' } }, processor: 'document'
        when 'text/rtf'
          obj.transform_datastream :content, { preservation: { format: 'odf' }, access: { format: 'pdf' }, thumbnail: { format: 'jpg' } }, processor: 'document'
        when 'application/msword'
          obj.transform_datastream :content, { access: { format: 'pdf' }, preservation: { format: 'docx' }, thumbnail: { format: 'jpg' } }, processor: 'document'
        when 'application/vnd.ms-excel'
          obj.transform_datastream :content, { access: { format: 'pdf' }, preservation: { format: 'xslx' }, thumbnail: { format: 'jpg' } }, processor: 'document'
        when 'image/tiff'
          obj.transform_datastream :content, {
            resized: { recipe: :default, resize: "600x600>", datastream: 'resized' },
            config_lookup: { recipe: :default, datastream: 'config_lookup' },
            string_recipe: { recipe: '-quiet', datastream: 'string_recipe' },
            diy: { }
          }, processor: 'jpeg2k_image'
        end

      end

      makes_derivatives :generate_special_derivatives

      def generate_special_derivatives
        if label == "special" && mime_type == 'image/png'
          transform_datastream :content, { medium: { size: "200x300>", datastream: 'special_ds' } }
        end
      end
    end
  end

  after(:all) do
    GenericFile.destroy_all
    Object.send(:remove_const, :GenericFile);
    Object.send(:remove_const, :ContentDatastream);
  end

  describe "with an attached image" do
    let(:attachment) { File.open(File.expand_path('../../fixtures/world.png', __FILE__))}
    let(:file) do
      GenericFile.new(mime_type: 'image/png').tap do |f|
        f.content.content = attachment
        f.save
      end
    end

    it "should transcode" do
      expect(file.datastreams.key?('content_medium')).to be_falsey
      file.create_derivatives
      expect(file.datastreams['content_medium']).to have_content
      expect(file.datastreams['content_medium'].mimeType).to eq('image/png')
      expect(file.datastreams['content_thumb']).to have_content
      expect(file.datastreams['content_thumb'].mimeType).to eq('image/png')
      expect(file.datastreams['access']).to have_content
      expect(file.datastreams['access'].mimeType).to eq('image/jpeg')
      expect(file.datastreams.key?('content_text')).to be_falsey
    end
  end

  describe "with an attached pdf" do
    let(:attachment) { File.open(File.expand_path('../../fixtures/test.pdf', __FILE__))}
    let(:file) { GenericFile.new(mime_type: 'application/pdf').tap { |t| t.content.content = attachment; t.save } }

    it "should transcode" do
      expect(file.datastreams.key?('content_thumb')).to be_falsey
      file.create_derivatives
      expect(file.datastreams['content_thumb']).to have_content
      expect(file.datastreams['content_thumb'].mimeType).to eq('image/png')
    end
  end

  describe "with an attached audio", unless: ENV['TRAVIS'] == 'true' do
    let(:attachment) { File.open(File.expand_path('../../fixtures/piano_note.wav', __FILE__))}
    let(:file) { GenericFile.new(mime_type: 'audio/wav').tap { |t| t.content.content = attachment; t.save } }

    it "should transcode" do
      file.create_derivatives
      expect(file.datastreams['content_mp3']).to have_content
      expect(file.datastreams['content_mp3'].mimeType).to eq('audio/mpeg')
      expect(file.datastreams['content_ogg']).to have_content
      expect(file.datastreams['content_ogg'].mimeType).to eq('audio/ogg')
    end
  end

  describe "when the source datastrem has an unknown mime_type", unless: ENV['TRAVIS'] == 'true' do
    let(:attachment) { File.open(File.expand_path('../../fixtures/piano_note.wav', __FILE__))}
    let(:file) { GenericFile.new(mime_type: 'audio/wav').tap { |t| t.content.content = attachment; t.content.mimeType = 'audio/vnd.wav'; t.save } }

    it "should transcode" do
      expect(logger).to receive(:warn).with("Unable to find a registered mime type for \"audio/vnd.wav\" on #{file.pid}").twice
      file.create_derivatives
      expect(file.datastreams['content_mp3']).to have_content
      expect(file.datastreams['content_mp3'].mimeType).to eq('audio/mpeg')
    end
  end

  describe "with an attached video", unless: ENV['TRAVIS'] == 'true' do
    let(:attachment) { File.open(File.expand_path('../../fixtures/countdown.avi', __FILE__))}
    let(:file) { GenericFile.new(mime_type: 'video/avi').tap { |t| t.content.content = attachment; t.save } }

    it "should transcode" do
      file.create_derivatives
      expect(file.datastreams['content_mp4']).to have_content
      expect(file.datastreams['content_mp4'].mimeType).to eq('video/mp4')
      expect(file.datastreams['content_webm']).to have_content
      expect(file.datastreams['content_webm'].mimeType).to eq('video/webm')
      expect(file.datastreams['thumbnail']).to have_content
      expect(file.datastreams['thumbnail'].mimeType).to eq('image/jpeg')
    end
  end

  describe "using callback methods" do
    let(:attachment) { File.open(File.expand_path('../../fixtures/world.png', __FILE__))}
    let(:file) { GenericFile.new(mime_type: 'image/png', label: "special").tap { |t| t.content.content = attachment; t.save } }

    it "should transcode" do
      expect(file.datastreams.key?('special_ds')).to be_falsey
      file.create_derivatives
      expect(file.datastreams['special_ds']).to have_content
      expect(file.datastreams['special_ds'].mimeType).to eq('image/png')
      expect(file.datastreams['special_ds']).to have_content
    end
  end

  describe "with an attached Powerpoint", unless: ENV['TRAVIS'] == 'true' do
    let(:attachment) { File.open(File.expand_path('../../fixtures/FlashPix.ppt', __FILE__))}
    let(:file) { GenericFile.new(mime_type: 'application/vnd.ms-powerpoint').tap { |t| t.content.content = attachment; t.save } }

    it "should transcode" do
      file.create_derivatives
      expect(file.datastreams['content_thumbnail']).to have_content
      expect(file.datastreams['content_thumbnail'].mimeType).to eq('image/jpeg')
      expect(file.datastreams['content_access']).to have_content
      expect(file.datastreams['content_access'].mimeType).to eq('application/pdf')
      expect(file.datastreams['content_preservation']).to have_content
      expect(file.datastreams['content_preservation'].mimeType).to eq('application/vnd.openxmlformats-officedocument.presentationml.presentation')
    end
  end

  describe "with an attached rich text format", unless: ENV['TRAVIS'] == 'true' do
    let(:attachment) { File.open(File.expand_path('../../fixtures/sample.rtf', __FILE__))}
    let(:file) { GenericFile.new(mime_type: 'text/rtf').tap { |t| t.content.content = attachment; t.save } }

    it "should transcode" do
      file.create_derivatives
      expect(file.datastreams['content_thumbnail']).to have_content
      expect(file.datastreams['content_thumbnail'].mimeType).to eq('image/jpeg')
      expect(file.datastreams['content_access']).to have_content
      expect(file.datastreams['content_access'].mimeType).to eq('application/pdf')
      expect(file.datastreams['content_preservation']).to have_content
      expect(file.datastreams['content_preservation'].mimeType).to eq('application/vnd.oasis.opendocument.text')
    end
  end

  describe "with an attached word doc format", unless: ENV['TRAVIS'] == 'true' do
    let(:attachment) { File.open(File.expand_path('../../fixtures/test.doc', __FILE__))}
    let(:file) { GenericFile.new(mime_type: 'application/msword').tap { |t| t.content.content = attachment; t.save } }

    it "should transcode" do
      file.create_derivatives
      expect(file.datastreams['content_thumbnail']).to have_content
      expect(file.datastreams['content_thumbnail'].mimeType).to eq('image/jpeg')
      expect(file.datastreams['content_access']).to have_content
      expect(file.datastreams['content_access'].mimeType).to eq('application/pdf')
      expect(file.datastreams['content_preservation']).to have_content
      expect(file.datastreams['content_preservation'].mimeType).to eq('application/vnd.openxmlformats-officedocument.wordprocessingml.document')
    end
  end

  describe "with an attached excel format", unless: ENV['TRAVIS'] == 'true' do
    let(:attachment) { File.open(File.expand_path('../../fixtures/test.xls', __FILE__))}
    let(:file) { GenericFile.new(mime_type: 'application/vnd.ms-excel').tap { |t| t.content.content = attachment; t.save } }

    it "should transcode" do
      file.create_derivatives
      expect(file.datastreams['content_thumbnail']).to have_content
      expect(file.datastreams['content_thumbnail'].mimeType).to eq('image/jpeg')
      expect(file.datastreams['content_access']).to have_content
      expect(file.datastreams['content_access'].mimeType).to eq('application/pdf')
      expect(file.datastreams['content_preservation']).to have_content
      expect(file.datastreams['content_preservation'].mimeType).to eq('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
    end
  end

  describe "with an attached tiff", unless: ENV['TRAVIS'] == 'true' do
    let(:attachment) { File.open(File.expand_path('../../fixtures/test.tif', __FILE__))}
    let(:file) { GenericFile.new(mime_type: 'image/tiff').tap { |t| t.content.content = attachment; t.save } }
    it "should transcode" do
      file.create_derivatives
      expect(file.datastreams['content_diy']).to have_content
      expect(file.datastreams['content_diy'].mimeType).to eq('image/jp2')
      expect(file.datastreams['config_lookup']).to have_content
      expect(file.datastreams['config_lookup'].mimeType).to eq('image/jp2')
      expect(file.datastreams['resized']).to have_content
      expect(file.datastreams['resized'].mimeType).to eq('image/jp2')
      expect(file.datastreams['string_recipe']).to have_content
      expect(file.datastreams['string_recipe'].mimeType).to eq('image/jp2')
    end
  end
end
