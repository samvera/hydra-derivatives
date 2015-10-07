require 'spec_helper'

describe "Transcoder" do
  before(:all) do
    class GenericFile < ActiveFedora::Base
      include Hydra::Derivatives
      contains 'characterization', class_name: 'ActiveFedora::SimpleDatastream' do |m|
        m.field "mime_type_from_fits", :string
        m.field "flag_as", :string
      end

      property :mime_type_from_fits, delegate_to: :characterization, multiple: false
      property :flag_as, delegate_to: :characterization, multiple: false
      contains 'original_file'

      def create_derivatives(filename)
        case mime_type_from_fits
        when 'application/pdf'
          PdfDerivatives.create(self, source: :original_file,
                                outputs: [{ label: :thumb, size: "100x100>", url: "#{uri}/original_file_thumb" }])
          FullTextExtract.create(self, source: :original_file, outputs: [{ url: "#{uri}/fulltext" }])
        when 'audio/wav'
          AudioDerivatives.create(self, source: :original_file, outputs: [{ label: :mp3, format: 'mp3', url: "#{uri}/mp3" }, { label: :ogg, format: 'ogg', url: "#{uri}/ogg" }])
        when 'video/avi'
          VideoDerivatives.create(self, source: :original_file,
                                  outputs: [
                                    { label: :mp4, format: 'mp4', url: "#{uri}/original_file_mp4" },
                                    { label: :webm, format: 'webm', url: "#{uri}/original_file_webm" },
                                    { label: :thumbnail, format: 'jpg', url: "#{uri}/thumbnail" }])
        when 'image/png', 'image/jpg'
          ImageDerivatives.create(self, source: :original_file,
                                  outputs: [
                                    { label: :medium, size: "300x300>", url: "#{uri}/original_file_medium" },
                                    { label: :thumb, size: "100x100>", url: "#{uri}/original_file_thumb" },
                                    { label: :access, url: "#{uri}/access", format: 'jpg' },
          ])
        when 'application/vnd.ms-powerpoint'
          DocumentDerivatives.create(self, source: :original_file, outputs: [{ label: :preservation, format: 'pptx' }, { label: :access, format: 'pdf' }, { label: :thumnail, format: 'jpg' }])
        when 'text/rtf'
          DocumentDerivatives.create(self, source: :original_file, outputs: [{ label: :preservation, format: 'odf' }, { label: :access, format: 'pdf' }, { label: :thumnail, format: 'jpg' }])
        when 'application/msword'
          DocumentDerivatives.create(self, source: :original_file, outputs: [{ label: :preservation, format: 'docx' }, { label: :access, format: 'pdf' }, { label: :thumnail, format: 'jpg' }])
        when 'application/vnd.ms-excel'
          DocumentDerivatives.create(self, source: :original_file, outputs: [{ label: :preservation, format: 'xslx' }, { label: :access, format: 'pdf' }, { label: :thumnail, format: 'jpg' }])
        when 'image/tiff'
          Jpeg2kImageDerivatives.create(self, source: :original_file, outputs: [
            { label: :resized, recipe: :default, resize: "600x600>", processor: 'jpeg2k_image', url: "#{uri}/resized" },
            { label: :config_lookup, recipe: :default, processor: 'jpeg2k_image', url: "#{uri}/config_lookup" },
            { label: :string_recipe, recipe: '-quiet', processor: 'jpeg2k_image', url: "#{uri}/string_recipe" },
            { label: :diy, processor: 'jpeg2k_image', url: "#{uri}/original_file_diy" }
          ])
        when 'image/x-adobe-dng'
          ImageDerivatives.create(self, source: :original_file, outputs: [
            { label: :access, size: "300x300>", format: 'jpg', processor: :raw_image },
            { label: :thumb, size: "100x100>", format: 'jpg', processor: :raw_image }
          ])
         end
      end
    end
  end

  after(:all) do
    Object.send(:remove_const, :GenericFile);
  end

  describe "with an attached image" do
    let(:filename) { File.expand_path('../../fixtures/world.png', __FILE__) }
    let(:attachment) { File.open(filename) }
    let(:file) do
      GenericFile.new(mime_type_from_fits: 'image/png') do |f|
        f.original_file.content = attachment
        f.save!
      end
    end

    it "should transcode" do
      expect(file.attached_files.key?('original_file_medium')).to be_falsey
      file.create_derivatives(filename)
      file.reload
      expect(file.attached_files['original_file_medium']).to have_content
      expect(file.attached_files['original_file_medium'].mime_type).to eq('image/png')
      expect(file.attached_files['original_file_thumb']).to have_content
      expect(file.attached_files['original_file_thumb'].mime_type).to eq('image/png')
      expect(file.attached_files['access']).to have_content
      expect(file.attached_files['access'].mime_type).to eq('image/jpeg')
      expect(file.attached_files.key?('original_file_text')).to be_falsey
    end
  end

  describe "with an attached RAW image", unless: $in_travis do
    let(:filename) { File.expand_path('../../fixtures/test.dng', __FILE__) }
    let(:attachment) { File.open(filename) }
    let(:file) do
      GenericFile.new(mime_type_from_fits: 'image/x-adobe-dng') do |f|
        f.original_file.content = attachment
        f.original_file.mime_type = 'image/x-adobe-dng'
        f.save!
      end
    end

    it "should transcode" do
     expect(file.attached_files.key?('access')).to be_falsey
      expect(file.attached_files.key?('thumb')).to be_falsey

      file.create_derivatives(filename)
      expect(file.attached_files['access']).to have_content
      expect(file.attached_files['access'].mime_type).to eq('image/jpeg')
      expect(file.attached_files['thumb']).to have_content
      expect(file.attached_files['thumb'].mime_type).to eq('image/jpeg')
    end
  end

  describe "with an attached pdf", unless: $in_travis do
    let(:filename) { File.expand_path('../../fixtures/test.pdf', __FILE__) }
    let(:attachment) { File.open(filename) }
    let(:file) do
      GenericFile.new(mime_type_from_fits: 'application/pdf') do |t|
        t.original_file.content = attachment
        t.original_file.mime_type = 'application/pdf'
        t.save
      end
    end

    it "should transcode" do
      expect(file.attached_files.key?('original_file_thumb')).to be_falsey
      file.create_derivatives(filename)
      file.reload
      expect(file.attached_files['original_file_thumb']).to have_content
      expect(file.attached_files['original_file_thumb'].mime_type).to eq('image/png')
      expect(file.attached_files['fulltext'].content).to match /This PDF file was created using CutePDF/
      expect(file.attached_files['fulltext'].mime_type).to eq 'text/plain'
    end
  end

  describe "with an attached audio", unless: $in_travis do
    let(:filename) { File.expand_path('../../fixtures/piano_note.wav', __FILE__) }
    let(:attachment) { File.open(filename) }
    let(:file) { GenericFile.new(mime_type_from_fits: 'audio/wav').tap { |t| t.original_file.content = attachment; t.save } }

    it "should transcode" do
      file.create_derivatives(filename)
      file.reload
      expect(file.attached_files['original_file_mp3']).to have_content
      expect(file.attached_files['original_file_mp3'].mime_type).to eq('audio/mpeg')
      expect(file.attached_files['original_file_ogg']).to have_content
      expect(file.attached_files['original_file_ogg'].mime_type).to eq('audio/ogg')
    end
  end

  describe "when the source datastrem has an unknown mime_type", unless: $in_travis do
    let(:filename) { File.expand_path('../../fixtures/piano_note.wav', __FILE__) }
    let(:attachment) { File.open(filename) }
    let(:file) do
      GenericFile.new(mime_type_from_fits: 'audio/wav').tap do |t|
        t.original_file.content = attachment;
        t.original_file.mime_type = 'audio/vnd.wav';
        t.save
      end
    end

    it "should transcode" do
      allow_any_instance_of(::Logger).to receive(:warn)
      file.create_derivatives(filename)
      file.reload
      expect(file.attached_files['original_file_mp3']).to have_content
      expect(file.attached_files['original_file_mp3'].mime_type).to eq('audio/mpeg')
    end
  end

  describe "with an attached video", unless: $in_travis do
    let(:filename) { File.expand_path('../../fixtures/countdown.avi', __FILE__) }
    let(:attachment) { File.open(filename) }
    let(:file) do
      GenericFile.create(mime_type_from_fits: 'video/avi') do |t|
        t.original_file.content = attachment
        t.original_file.mime_type = 'video/msvideo'
      end
    end

    it "should transcode" do
      file.create_derivatives(filename)
      file.reload
      expect(file.attached_files['original_file_mp4']).to have_content
      expect(file.attached_files['original_file_mp4'].mime_type).to eq('video/mp4')
      expect(file.attached_files['original_file_webm']).to have_content
      expect(file.attached_files['original_file_webm'].mime_type).to eq('video/webm')
      expect(file.attached_files['thumbnail']).to have_content
      expect(file.attached_files['thumbnail'].mime_type).to eq('image/jpeg')
    end

    context "and the timeout is set" do
      before do
        Hydra::Derivatives::Processors::Video::Processor.timeout = 0.2 # 200ms
      end
      after do
        Hydra::Derivatives::Processors::Video::Processor.timeout = nil # clear timeout
      end

      it "should raise a timeout" do
        expect { file.create_derivatives(filename) }.to raise_error Hydra::Derivatives::TimeoutError
      end
    end
  end

  describe "with an attached Powerpoint", unless: $in_travis do
    let(:filename) { File.expand_path('../../fixtures/FlashPix.ppt', __FILE__) }
    let(:attachment) { File.open(filename) }
    let(:file) do
      GenericFile.create(mime_type_from_fits: 'application/vnd.ms-powerpoint') do |t|
        t.original_file.content = attachment
      end
    end

    it "should transcode" do
      file.create_derivatives(filename)
      file.reload
      expect(file.attached_files['original_file_thumbnail']).to have_content
      expect(file.attached_files['original_file_thumbnail'].mime_type).to eq('image/jpeg')
      expect(file.attached_files['original_file_access']).to have_content
      expect(file.attached_files['original_file_access'].mime_type).to eq('application/pdf')
      expect(file.attached_files['original_file_preservation']).to have_content
      expect(file.attached_files['original_file_preservation'].mime_type).to eq('application/vnd.openxmlformats-officedocument.presentationml.presentation')
    end
  end

  describe "with an attached rich text format", unless: $in_travis do
    let(:filename) { File.expand_path('../../fixtures/sample.rtf', __FILE__) }
    let(:attachment) { File.open(filename) }
    let(:file) { GenericFile.new(mime_type_from_fits: 'text/rtf').tap { |t| t.original_file.content = attachment; t.save } }

    it "should transcode" do
      file.create_derivatives(filename)
      file.reload
      expect(file.attached_files['original_file_thumbnail']).to have_content
      expect(file.attached_files['original_file_thumbnail'].mime_type).to eq('image/jpeg')
      expect(file.attached_files['original_file_access']).to have_content
      expect(file.attached_files['original_file_access'].mime_type).to eq('application/pdf')
      expect(file.attached_files['original_file_preservation']).to have_content
      expect(file.attached_files['original_file_preservation'].mime_type).to eq('application/vnd.oasis.opendocument.text')
    end
  end

  describe "with an attached word doc format", unless: $in_travis do
    let(:filename) { File.expand_path('../../fixtures/test.doc', __FILE__) }
    let(:attachment) { File.open(filename) }
    let(:file) { GenericFile.new(mime_type_from_fits: 'application/msword').tap { |t| t.original_file.content = attachment; t.save } }

    it "should transcode" do
      file.create_derivatives(filename)
      file.reload
      expect(file.attached_files['original_file_thumbnail']).to have_content
      expect(file.attached_files['original_file_thumbnail'].mime_type).to eq('image/jpeg')
      expect(file.attached_files['original_file_access']).to have_content
      expect(file.attached_files['original_file_access'].mime_type).to eq('application/pdf')
      expect(file.attached_files['original_file_preservation']).to have_content
      expect(file.attached_files['original_file_preservation'].mime_type).to eq('application/vnd.openxmlformats-officedocument.wordprocessingml.document')
    end
  end

  describe "with an attached excel format", unless: $in_travis do
    let(:filename) { File.expand_path('../../fixtures/test.xls', __FILE__) }
    let(:attachment) { File.open(filename)}
    let(:file) { GenericFile.new(mime_type_from_fits: 'application/vnd.ms-excel').tap { |t| t.original_file.content = attachment; t.save } }

    it "should transcode" do
      file.create_derivatives(filename)
      file.reload
      expect(file.attached_files['original_file_thumbnail']).to have_content
      expect(file.attached_files['original_file_thumbnail'].mime_type).to eq('image/jpeg')
      expect(file.attached_files['original_file_access']).to have_content
      expect(file.attached_files['original_file_access'].mime_type).to eq('application/pdf')
      expect(file.attached_files['original_file_preservation']).to have_content
      expect(file.attached_files['original_file_preservation'].mime_type).to eq('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
    end
  end

  describe "with an attached tiff", unless: $in_travis do
    let(:filename) { File.expand_path('../../fixtures/test.tif', __FILE__) }
    let(:attachment) { File.open(filename)}
    let(:file) { GenericFile.new(mime_type_from_fits: 'image/tiff').tap { |t| t.original_file.content = attachment; t.save } }
    it "should transcode" do
      file.create_derivatives(filename)
      file.reload
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
