require 'spec_helper'

describe "Transcoder" do
  before(:all) do
    class ContentDatastream < ActiveFedora::File
      include Hydra::Derivatives::ExtractMetadata
    end

    class GenericFile < ActiveFedora::Base
      include Hydra::Derivatives
      contains 'characterization', class_name: 'ActiveFedora::SimpleDatastream' do |m|
        m.field "mime_type_from_fits", :string
        m.field "flag_as", :string
      end

      has_attributes :mime_type_from_fits, :flag_as, datastream: :characterization, multiple: false
      contains 'original_file', class_name: 'ContentDatastream'

      makes_derivatives do |obj|
        case obj.mime_type_from_fits
        when 'application/pdf'
          obj.transform_file :original_file, { thumb: '100x100>' }
        when 'audio/wav'
          obj.transform_file :original_file, { mp3: { format: 'mp3' }, ogg: { format: 'ogg'} }, processor: :audio
        when 'video/avi'
          obj.transform_file :original_file, { mp4: { format: 'mp4' }, webm: { format: 'webm'}, thumbnail: { format: 'jpg', datastream: 'thumbnail' } }, processor: :video
        when 'image/png', 'image/jpg'
          obj.transform_file :original_file, { medium: "300x300>", thumb: "100x100>", access: { format: 'jpg', datastream: 'access'} }
        when 'application/vnd.ms-powerpoint'
          obj.transform_file :original_file, { preservation: { format: 'pptx'}, access: { format: 'pdf' }, thumbnail: { format: 'jpg' } }, processor: 'document'
        when 'text/rtf'
          obj.transform_file :original_file, { preservation: { format: 'odf' }, access: { format: 'pdf' }, thumbnail: { format: 'jpg' } }, processor: 'document'
        when 'application/msword'
          obj.transform_file :original_file, { access: { format: 'pdf' }, preservation: { format: 'docx' }, thumbnail: { format: 'jpg' } }, processor: 'document'
        when 'application/vnd.ms-excel'
          obj.transform_file :original_file, { access: { format: 'pdf' }, preservation: { format: 'xslx' }, thumbnail: { format: 'jpg' } }, processor: 'document'
        when 'image/tiff'
          obj.transform_file :original_file, {
            resized: { recipe: :default, resize: "600x600>", datastream: 'resized' },
            config_lookup: { recipe: :default, datastream: 'config_lookup' },
            string_recipe: { recipe: '-quiet', datastream: 'string_recipe' },
            diy: { }
          }, processor: 'jpeg2k_image'
        end

      end

      makes_derivatives :generate_special_derivatives

      def generate_special_derivatives
        if flag_as == "special" && mime_type_from_fits == 'image/png'
          transform_file :original_file, { medium: { size: "200x300>", datastream: 'special_ds' } }
        end
      end
    end
  end

  after(:all) do
    Object.send(:remove_const, :GenericFile);
    Object.send(:remove_const, :ContentDatastream);
  end

  describe "with an attached image" do
    let(:attachment) { File.open(File.expand_path('../../fixtures/world.png', __FILE__))}
    let(:file) do
      GenericFile.new(mime_type_from_fits: 'image/png').tap do |f|
        f.original_file.content = attachment
        f.save!
      end
    end

    it "should transcode" do
      expect(file.attached_files.key?('original_file_medium')).to be_falsey
      file.create_derivatives
      expect(file.attached_files['original_file_medium']).to have_content
      expect(file.attached_files['original_file_medium'].mime_type).to eq('image/png')
      expect(file.attached_files['original_file_thumb']).to have_content
      expect(file.attached_files['original_file_thumb'].mime_type).to eq('image/png')
      expect(file.attached_files['access']).to have_content
      expect(file.attached_files['access'].mime_type).to eq('image/jpeg')
      expect(file.attached_files.key?('original_file_text')).to be_falsey
    end
  end

  describe "with an attached pdf" do
    let(:attachment) { File.open(File.expand_path('../../fixtures/test.pdf', __FILE__))}
    let(:file) { GenericFile.new(mime_type_from_fits: 'application/pdf').tap { |t| t.original_file.content = attachment; t.save } }

    it "should transcode" do
      expect(file.attached_files.key?('original_file_thumb')).to be_falsey
      file.create_derivatives
      expect(file.attached_files['original_file_thumb']).to have_content
      expect(file.attached_files['original_file_thumb'].mime_type).to eq('image/png')
    end
  end

  describe "with an attached audio", unless: ENV['TRAVIS'] == 'true' do
    let(:attachment) { File.open(File.expand_path('../../fixtures/piano_note.wav', __FILE__))}
    let(:file) { GenericFile.new(mime_type_from_fits: 'audio/wav').tap { |t| t.original_file.content = attachment; t.save } }

    it "should transcode" do
      file.create_derivatives
      expect(file.attached_files['original_file_mp3']).to have_content
      expect(file.attached_files['original_file_mp3'].mime_type).to eq('audio/mpeg')
      expect(file.attached_files['original_file_ogg']).to have_content
      expect(file.attached_files['original_file_ogg'].mime_type).to eq('audio/ogg')
    end
  end

  describe "when the source datastrem has an unknown mime_type", unless: ENV['TRAVIS'] == 'true' do
    let(:attachment) { File.open(File.expand_path('../../fixtures/piano_note.wav', __FILE__))}
    let(:file) do
      GenericFile.new(mime_type_from_fits: 'audio/wav').tap do |t|
        t.original_file.content = attachment;
        t.original_file.mime_type = 'audio/vnd.wav';
        t.save
      end
    end

    it "should transcode" do
      allow_any_instance_of(::Logger).to receive(:warn)
      file.create_derivatives
      expect(file.attached_files['original_file_mp3']).to have_content
      expect(file.attached_files['original_file_mp3'].mime_type).to eq('audio/mpeg')
    end
  end

  describe "with an attached video", unless: ENV['TRAVIS'] == 'true' do
    let(:attachment) { File.open(File.expand_path('../../fixtures/countdown.avi', __FILE__))}
    let(:file) { GenericFile.new(mime_type_from_fits: 'video/avi').tap { |t| t.original_file.content = attachment; t.save } }

    it "should transcode" do
      file.create_derivatives
      expect(file.attached_files['original_file_mp4']).to have_content
      expect(file.attached_files['original_file_mp4'].mime_type).to eq('video/mp4')
      expect(file.attached_files['original_file_webm']).to have_content
      expect(file.attached_files['original_file_webm'].mime_type).to eq('video/webm')
      expect(file.attached_files['thumbnail']).to have_content
      expect(file.attached_files['thumbnail'].mime_type).to eq('image/jpeg')
    end

    context "and the timeout is set" do
      before do
        Hydra::Derivatives::Video::Processor.timeout = 1 # one second
      end
      after do
        Hydra::Derivatives::Video::Processor.timeout = nil # clear timeout
      end

      it "should raise a timeout" do
        expect { file.create_derivatives }.to raise_error Hydra::Derivatives::TimeoutError
      end
    end
  end

  describe "using callback methods" do
    let(:attachment) { File.open(File.expand_path('../../fixtures/world.png', __FILE__))}
    let(:file) { GenericFile.new(mime_type_from_fits: 'image/png', flag_as: "special").tap { |t| t.original_file.content = attachment; t.save } }

    it "should transcode" do
      expect(file.attached_files.key?('special_ds')).to be_falsey
      file.create_derivatives
      expect(file.attached_files['special_ds']).to have_content
      expect(file.attached_files['special_ds'].mime_type).to eq('image/png')
      expect(file.attached_files['special_ds']).to have_content
    end
  end

  describe "with an attached Powerpoint", unless: ENV['TRAVIS'] == 'true' do
    let(:attachment) { File.open(File.expand_path('../../fixtures/FlashPix.ppt', __FILE__))}
    let(:file) { GenericFile.new(mime_type_from_fits: 'application/vnd.ms-powerpoint').tap { |t| t.original_file.content = attachment; t.save } }

    it "should transcode" do
      file.create_derivatives
      expect(file.attached_files['original_file_thumbnail']).to have_content
      expect(file.attached_files['original_file_thumbnail'].mime_type).to eq('image/jpeg')
      expect(file.attached_files['original_file_access']).to have_content
      expect(file.attached_files['original_file_access'].mime_type).to eq('application/pdf')
      expect(file.attached_files['original_file_preservation']).to have_content
      expect(file.attached_files['original_file_preservation'].mime_type).to eq('application/vnd.openxmlformats-officedocument.presentationml.presentation')
    end
  end

  describe "with an attached rich text format", unless: ENV['TRAVIS'] == 'true' do
    let(:attachment) { File.open(File.expand_path('../../fixtures/sample.rtf', __FILE__))}
    let(:file) { GenericFile.new(mime_type_from_fits: 'text/rtf').tap { |t| t.original_file.content = attachment; t.save } }

    it "should transcode" do
      file.create_derivatives
      expect(file.attached_files['original_file_thumbnail']).to have_content
      expect(file.attached_files['original_file_thumbnail'].mime_type).to eq('image/jpeg')
      expect(file.attached_files['original_file_access']).to have_content
      expect(file.attached_files['original_file_access'].mime_type).to eq('application/pdf')
      expect(file.attached_files['original_file_preservation']).to have_content
      expect(file.attached_files['original_file_preservation'].mime_type).to eq('application/vnd.oasis.opendocument.text')
    end
  end

  describe "with an attached word doc format", unless: ENV['TRAVIS'] == 'true' do
    let(:attachment) { File.open(File.expand_path('../../fixtures/test.doc', __FILE__))}
    let(:file) { GenericFile.new(mime_type_from_fits: 'application/msword').tap { |t| t.original_file.content = attachment; t.save } }

    it "should transcode" do
      file.create_derivatives
      expect(file.attached_files['original_file_thumbnail']).to have_content
      expect(file.attached_files['original_file_thumbnail'].mime_type).to eq('image/jpeg')
      expect(file.attached_files['original_file_access']).to have_content
      expect(file.attached_files['original_file_access'].mime_type).to eq('application/pdf')
      expect(file.attached_files['original_file_preservation']).to have_content
      expect(file.attached_files['original_file_preservation'].mime_type).to eq('application/vnd.openxmlformats-officedocument.wordprocessingml.document')
    end
  end

  describe "with an attached excel format", unless: ENV['TRAVIS'] == 'true' do
    let(:attachment) { File.open(File.expand_path('../../fixtures/test.xls', __FILE__))}
    let(:file) { GenericFile.new(mime_type_from_fits: 'application/vnd.ms-excel').tap { |t| t.original_file.content = attachment; t.save } }

    it "should transcode" do
      file.create_derivatives
      expect(file.attached_files['original_file_thumbnail']).to have_content
      expect(file.attached_files['original_file_thumbnail'].mime_type).to eq('image/jpeg')
      expect(file.attached_files['original_file_access']).to have_content
      expect(file.attached_files['original_file_access'].mime_type).to eq('application/pdf')
      expect(file.attached_files['original_file_preservation']).to have_content
      expect(file.attached_files['original_file_preservation'].mime_type).to eq('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
    end
  end

  describe "with an attached tiff", unless: ENV['TRAVIS'] == 'true' do
    let(:attachment) { File.open(File.expand_path('../../fixtures/test.tif', __FILE__))}
    let(:file) { GenericFile.new(mime_type_from_fits: 'image/tiff').tap { |t| t.original_file.content = attachment; t.save } }
    it "should transcode" do
      file.create_derivatives
      expect(file.attached_files['original_file_diy']).to have_content
      expect(file.attached_files['original_file_diy'].mime_type).to eq('image/jp2')
      expect(file.attached_files['config_lookup']).to have_content
      expect(file.attached_files['config_lookup'].mime_type).to eq('image/jp2')
      expect(file.attached_files['resized']).to have_content
      expect(file.attached_files['resized'].mime_type).to eq('image/jp2')
      expect(file.attached_files['string_recipe']).to have_content
      expect(file.attached_files['string_recipe'].mime_type).to eq('image/jp2')
    end
  end
end
