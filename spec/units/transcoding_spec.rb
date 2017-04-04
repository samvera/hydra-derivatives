require 'spec_helper'

describe "Transcoding" do
  before(:all) do
    class GenericFile < ActiveFedora::Base
      include Hydra::Derivatives
      property :mime_type_from_fits, predicate: ::RDF::URI('http://example.com/mime'), multiple: false
      has_subresource 'original_file'

      def create_derivatives(_filename)
        case mime_type_from_fits
        when 'application/pdf'
          PdfDerivatives.create(self, source: :original_file,
                                      outputs: [{ label: :thumb, size: "100x100>", url: "#{uri}/original_file_thumb" }])
          FullTextExtract.create(self, source: :original_file, outputs: [{ url: "#{uri}/fulltext" }])
        when 'audio/x-wav'
          AudioDerivatives.create(self, source: :original_file,
                                        outputs: [
                                          { label: :mp3, format: 'mp3', url: "#{uri}/original_file_mp3" },
                                          { label: :ogg, format: 'ogg', url: "#{uri}/original_file_ogg" }])
        when 'video/x-msvideo'
          VideoDerivatives.create(self, source: :original_file,
                                        outputs: [
                                          { label: :mp4,       format: 'mp4',  url: "#{uri}/original_file_mp4" },
                                          { label: :webm,      format: 'webm', url: "#{uri}/original_file_webm" },
                                          { label: :thumbnail, format: 'jpg',  url: "#{uri}/thumbnail" }])
        when 'image/png', 'image/jpg'
          ImageDerivatives.create(self, source: :original_file,
                                  outputs: [
                                    { label: :medium, size: "300x300>", url: "#{uri}/original_file_medium" },
                                    { label: :thumb,  size: "100x100>", url: "#{uri}/original_file_thumb" },
                                    { label: :access, format: 'jpg',    url: "#{uri}/access" },
          ])
        when 'application/vnd.ms-powerpoint'
          DocumentDerivatives.create(self, source: :original_file,
                                           outputs: [
                                             { label: :preservation, format: 'pptx', url: "#{uri}/original_file_preservation" },
                                             { label: :access,       format: 'pdf',  url: "#{uri}/original_file_access" },
                                             { label: :thumnail,     format: 'jpg',  url: "#{uri}/original_file_thumbnail" }])
        when 'text/rtf'
          DocumentDerivatives.create(self, source: :original_file,
                                           outputs: [
                                             { label: :preservation, format: 'odt', url: "#{uri}/original_file_preservation" },
                                             { label: :access,       format: 'pdf', url: "#{uri}/original_file_access" },
                                             { label: :thumnail,     format: 'jpg', url: "#{uri}/original_file_thumbnail" }])
        when 'application/msword'
          DocumentDerivatives.create(self, source: :original_file,
                                           outputs: [
                                             { label: :preservation, format: 'docx', url: "#{uri}/original_file_preservation" },
                                             { label: :access,       format: 'pdf',  url: "#{uri}/original_file_access" },
                                             { label: :thumnail,     format: 'jpg',  url: "#{uri}/original_file_thumbnail" }])
        when 'application/vnd.ms-excel'
          DocumentDerivatives.create(self, source: :original_file,
                                           outputs: [
                                             { label: :preservation, format: 'xlsx', url: "#{uri}/original_file_preservation" },
                                             { label: :access,       format: 'pdf',  url: "#{uri}/original_file_access" },
                                             { label: :thumnail,     format: 'jpg',  url: "#{uri}/original_file_thumbnail" }])
        when 'image/tiff'
          Jpeg2kImageDerivatives.create(self, source: :original_file,
                                              outputs: [
                                                { label: :resized,       format: 'jp2', recipe: :default, processor: 'jpeg2k_image', resize: "600x600>", url: "#{uri}/resized" },
                                                { label: :config_lookup, format: 'jp2', recipe: :default, processor: 'jpeg2k_image', url: "#{uri}/config_lookup" },
                                                { label: :string_recipe, format: 'jp2', recipe: '-jp2_space sRGB', processor: 'jpeg2k_image', url: "#{uri}/string_recipe" },
                                                { label: :diy,           format: 'jp2', processor: 'jpeg2k_image', url: "#{uri}/original_file_diy" }])
        when 'image/x-adobe-dng'
          ImageDerivatives.create(self, source: :original_file,
                                        outputs: [
                                          { label: :access, size: "300x300>", format: 'jpg', processor: :raw_image, url: "#{uri}/original_file_access" },
                                          { label: :thumb,  size: "100x100>", format: 'jpg', processor: :raw_image, url: "#{uri}/original_file_thumb" }])
        end
      end
    end
  end

  after(:all) do
    Object.send(:remove_const, :GenericFile)
  end

  describe "with an attached image" do
    let(:filename) { File.expand_path('../../fixtures/world.png', __FILE__) }
    let(:attachment) { File.open(filename) }
    let(:file) do
      GenericFile.new(mime_type_from_fits: 'image/png') do |f|
        f.original_file.content = attachment
        f.original_file.mime_type = f.mime_type_from_fits
        f.save!
      end
    end

    it "transcodes" do
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

  describe "with an attached RAW image", requires_imagemagick: true do
    let(:filename) { File.expand_path('../../fixtures/test.dng', __FILE__) }
    let(:attachment) { File.open(filename) }
    let(:file) do
      GenericFile.new(mime_type_from_fits: 'image/x-adobe-dng') do |f|
        f.original_file.content = attachment
        f.original_file.mime_type = f.mime_type_from_fits
        f.save!
      end
    end

    it "transcodes" do
      expect(file.attached_files.key?('original_file_access')).to be_falsey
      expect(file.attached_files.key?('original_file_thumb')).to be_falsey

      file.create_derivatives(filename)
      file.reload
      expect(file.attached_files['original_file_access']).to have_content
      expect(file.attached_files['original_file_access'].mime_type).to eq('image/jpeg')
      expect(file.attached_files['original_file_thumb']).to have_content
      expect(file.attached_files['original_file_thumb'].mime_type).to eq('image/jpeg')
    end
  end

  describe "with an attached pdf", requires_imagemagick: true do
    let(:filename) { File.expand_path('../../fixtures/test.pdf', __FILE__) }
    let(:attachment) { File.open(filename) }
    let(:file) do
      GenericFile.new(mime_type_from_fits: 'application/pdf') do |t|
        t.original_file.content = attachment
        t.original_file.mime_type = t.mime_type_from_fits
        t.save
      end
    end

    it "transcodes" do
      expect(file.attached_files.key?('original_file_thumb')).to be_falsey
      file.create_derivatives(filename)
      file.reload
      expect(file.attached_files['original_file_thumb']).to have_content
      expect(file.attached_files['original_file_thumb'].mime_type).to eq('image/png')
      expect(file.attached_files['fulltext'].content).to match(/This PDF file was created using CutePDF/)
      expect(file.attached_files['fulltext'].mime_type).to eq 'text/plain'
    end
  end

  describe "with an attached audio", requires_ffmpeg: true do
    let(:filename) { File.expand_path('../../fixtures/piano_note.wav', __FILE__) }
    let(:attachment) { File.open(filename) }
    let(:file) do
      GenericFile.new(mime_type_from_fits: 'audio/x-wav').tap do |t|
        t.original_file.content = attachment
        t.original_file.mime_type = t.mime_type_from_fits
        t.save
      end
    end

    it "transcodes" do
      file.create_derivatives(filename)
      file.reload
      expect(file.attached_files['original_file_mp3']).to have_content
      expect(file.attached_files['original_file_mp3'].mime_type).to eq('audio/mpeg')
      expect(file.attached_files['original_file_ogg']).to have_content
      expect(file.attached_files['original_file_ogg'].mime_type).to eq('audio/ogg')
    end
  end

  describe "when the source datastrem has an unknown mime_type", requires_ffmpeg: true do
    let(:filename) { File.expand_path('../../fixtures/piano_note.wav', __FILE__) }
    let(:attachment) { File.open(filename) }
    let(:file) do
      GenericFile.new(mime_type_from_fits: 'audio/x-wav').tap do |t|
        t.original_file.content = attachment
        t.original_file.mime_type = 'audio/vnd.wav'
        t.save
      end
    end

    it "transcodes" do
      allow_any_instance_of(::Logger).to receive(:warn)
      file.create_derivatives(filename)
      file.reload
      expect(file.attached_files['original_file_mp3']).to have_content
      expect(file.attached_files['original_file_mp3'].mime_type).to eq('audio/mpeg')
    end
  end

  describe "with an attached video", requires_ffmpeg: true do
    let(:filename) { File.expand_path('../../fixtures/countdown.avi', __FILE__) }
    let(:attachment) { File.open(filename) }
    let(:file) do
      GenericFile.create(mime_type_from_fits: 'video/x-msvideo') do |t|
        t.original_file.content = attachment
        t.original_file.mime_type = t.mime_type_from_fits
        t.save
      end
    end

    it "transcodes" do
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

      it "raises a timeout" do
        expect { file.create_derivatives(filename) }.to raise_error Hydra::Derivatives::TimeoutError
      end
    end
  end

  describe "with an attached Powerpoint", requires_libreoffice: true do
    let(:filename) { File.expand_path('../../fixtures/FlashPix.ppt', __FILE__) }
    let(:attachment) { File.open(filename) }
    let(:file) do
      GenericFile.create(mime_type_from_fits: 'application/vnd.ms-powerpoint') do |t|
        t.original_file.content = attachment
        t.original_file.mime_type = t.mime_type_from_fits
        t.save
      end
    end

    it "transcodes" do
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

  describe "with an attached rich text format", requires_libreoffice: true do
    let(:filename) { File.expand_path('../../fixtures/sample.rtf', __FILE__) }
    let(:attachment) { File.open(filename) }
    let(:file) do
      GenericFile.new(mime_type_from_fits: 'text/rtf').tap do |t|
        t.original_file.content = attachment
        t.original_file.mime_type = t.mime_type_from_fits
        t.save
      end
    end

    it "transcodes" do
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

  describe "with an attached word doc format", requires_libreoffice: true do
    let(:filename)   { File.expand_path('../../fixtures/test.doc', __FILE__) }
    let(:attachment) { File.open(filename) }

    let(:file) do
      GenericFile.new(mime_type_from_fits: 'application/msword').tap do |t|
        t.original_file.content = attachment
        t.original_file.mime_type = t.mime_type_from_fits
        t.save
      end
    end

    it "transcodes" do
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

  describe "with an attached excel format", requires_libreoffice: true do
    let(:filename)   { File.expand_path('../../fixtures/test.xls', __FILE__) }
    let(:attachment) { File.open(filename) }

    let(:file) do
      GenericFile.new(mime_type_from_fits: 'application/vnd.ms-excel').tap do |t|
        t.original_file.content = attachment
        t.original_file.mime_type = t.mime_type_from_fits
        t.save
      end
    end

    it "transcodes" do
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

  describe "with an attached tiff", requires_kdu_compress: true do
    let(:filename) { File.expand_path('../../fixtures/test.tif', __FILE__) }
    let(:attachment) { File.open(filename) }

    let(:file) do
      GenericFile.new(mime_type_from_fits: 'image/tiff').tap do |t|
        t.original_file.content = attachment
        t.original_file.mime_type = t.mime_type_from_fits
        t.save
      end
    end

    it "transcodes" do
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
