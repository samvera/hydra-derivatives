require 'spec_helper'

describe Hydra::Derivatives do
  before(:all) do
    class CustomFile < ActiveFedora::Base
      include Hydra::Derivatives
    end
    class CustomProcessor < Hydra::Derivatives::Processor
    end
    class CustomSourceFileService
    end
    class CustomOutputFileService
    end
  end

  after(:all)  do
    Object.send(:remove_const, :CustomFile)
    Object.send(:remove_const, :CustomProcessor)
    Object.send(:remove_const, :CustomSourceFileService)
    Object.send(:remove_const, :CustomOutputFileService)
  end

  describe "initialize_processor" do
    subject do
      CustomFile.new.send(:initialize_processor, '/opt/originals/foo.mov',
                          :content, { thumb: '100x100>' },
                          processor: Hydra::Derivatives::Video::Processor,
                          output_file_service: CustomOutputFileService)
    end

    it "accepts arguments to override the defaults" do
      expect(subject.class).to eq(Hydra::Derivatives::Video::Processor)
      expect(subject.output_file_service).to eq(CustomOutputFileService)
    end
  end

  describe "source_file" do
    subject { CustomFile.new }

    it "relies on the source_file_service" do
      expect(subject.source_file_service).to receive(:call).with(subject, :content)
      subject.source_file(:content)
    end
  end


  describe "source_file_service" do
    let(:custom_source_file_service) { "fake service" }
    before do
      allow(Hydra::Derivatives).to receive(:source_file_service).and_return(custom_source_file_service)
    end
    subject { Class.new { include Hydra::Derivatives } }

    context "as a global configuration setting" do
      it "utilizes the default source file service" do
        expect(subject.source_file_service).to eq(custom_source_file_service)
      end
    end

    context "as an instance level configuration setting" do
      let(:another_custom_source_file_service) { "another fake service" }
      subject { Class.new { include Hydra::Derivatives }.new }
      before { subject.source_file_service = another_custom_source_file_service }

      it "accepts a custom source file service as an option" do
        expect(subject.source_file_service).to eq(another_custom_source_file_service)
      end
    end
  end

  describe "transform_file" do
    context "reading from a local file" do
      before do
        class LocalFileService
          def self.call(object, source_name, &block)
            yield File.open(source_name)
          end
        end
      end

      let(:mock_storage) { double }

      subject { Class.new { include Hydra::Derivatives }.new }
      before do
        subject.source_file_service = LocalFileService
        allow(mock_storage).to receive(:call).with(subject, duck_type(:read, :path), "spec/fixtures/countdown.avi_mp4")
      end

      it "allows us to transform a local file", unless: $in_travis do
        subject.transform_file 'spec/fixtures/countdown.avi', { mp4: { format: 'mp4' } }, processor: :video, output_file_service: mock_storage
      end
    end
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
