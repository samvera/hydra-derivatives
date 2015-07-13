require 'spec_helper'

describe Hydra::Derivatives::RetrieveSourceFileService do

  before(:all) do
    class IndirectContainerObject < ActiveFedora::Base
      contains "the_source_name"
    end

    class DirectContainerObject < ActiveFedora::Base
      directly_contains :files, has_member_relation: ::RDF::URI("http://pcdm.org/use#hasFile"),
        class_name: "ActiveFedora::Base"
      directly_contains_one :original_file, through: :files, type: ::RDF::URI("http://pcdm.org/use#OriginalFile")
      directly_contains_one :thumbnail, through: :files, type: ::RDF::URI("http://pcdm.org/use#ThumbnailImage")
      directly_contains_one :extracted_text, through: :files, type: ::RDF::URI("http://pcdm.org/use#ExtractedText")
    end
  end

  let(:object)            { IndirectContainerObject.new  }
  let(:file_path)         { File.join(fixture_path, 'test.pdf') }
  let(:file)              { File.new(file_path)}
  let(:type_uri)          { ::RDF::URI("http://sample.org/SourceFile") }
  let(:source_name)       { 'the_source_name' }

  context "when file is indirectly contained (default assumption)" do  # alas, we have to support this as the default because all legacy code (and fedora 3 systems) created indirectly contained files
    let(:object)            { IndirectContainerObject.new  }
    before do
      # attaches the file as an indirectly contained object
      object.the_source_name.content = "fake file content"
    end
    it "persists the file to the specified destination on the given object" do
      described_class.call(object, source_name)
      expect(object.send(source_name).content).to eq("fake file content")
    end
  end

  context "when file is directly contained" do  # direct containers are more efficient, but most legacy code will have indirect containers
    let(:object)          { DirectContainerObject.create }
    before do
      object.build_original_file
      object.original_file.content = "fake file content"
    end
    it "retrieves the file from the specified location on the given object" do
      expect(object.original_file.content).to eq("fake file content")
    end
  end
  
end