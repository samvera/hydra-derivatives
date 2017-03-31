require 'spec_helper'

describe Hydra::Derivatives::AudioDerivatives do
  describe ".create" do
    let(:filename) { 'spec/fixtures/piano_note.wav' }
    let(:af_path) { ActiveFedora.fedora.host + ActiveFedora.fedora.base_path }

    context "with a filename", requires_ffmpeg: true do
      before do
        class LocalFileService
          def self.call(file_name, _options, &_block)
            yield File.open(file_name)
          end
        end
        described_class.source_file_service = LocalFileService
      end

      after do
        # restore the default
        described_class.source_file_service = Hydra::Derivatives::RetrieveSourceFileService
        Object.send(:remove_const, :LocalFileService)
      end

      it "creates derivatives" do
        described_class.create(filename,
                               outputs: [{ label: 'mp3', format: 'mp3', url: "#{af_path}/1234/mp3" },
                                         { label: 'ogg', format: 'ogg', url: "#{af_path}/1234/ogg" }])
      end
    end

    context "with an object" do
      let(:object)      { "Fake Object" }
      let(:source_name) { :content }
      let(:file)        { double("the file") }

      before do
        allow(object).to receive(:original_file).and_return(file)
        allow(Hydra::Derivatives::TempfileService).to receive(:create).with(file)
      end

      it "creates derivatives" do
        described_class.create(object,
                               source: :original_file,
                               outputs: [{ label: 'mp3', format: 'mp3' },
                                         { label: 'ogg', format: 'ogg' }])
      end
    end
  end

  describe "source_file" do
    subject { described_class }

    it "relies on the source_file_service" do
      expect(subject.source_file_service).to receive(:call).with('foo/bar.aiff', baz: true)
      subject.source_file('foo/bar.aiff', baz: true)
    end
  end

  describe "output_file_service" do
    before do
      class FakeOutputService
      end
      Hydra::Derivatives.output_file_service = FakeOutputService
    end

    after do
      # restore the default
      Hydra::Derivatives.output_file_service = Hydra::Derivatives::PersistBasicContainedOutputFileService
      Object.send(:remove_const, :FakeOutputService)
    end

    subject { described_class.output_file_service }

    it "defaults to the value set on Hydra::Derivatives" do
      expect(subject).to eq FakeOutputService
    end
  end
end
