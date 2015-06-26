require 'spec_helper'
require 'hydra/works'

describe Hydra::Derivatives::RetrieveSourceFileService do

  before(:all) do
    class IndirectContainerObject < ActiveFedora::Base
      contains "the_source_name"
    end

    # This uses directly_contains (inherited from Hydra::PCDM::ObjectBehavior)
    # If you manually built DirectContainerObject, it would look like this:
    # class DirectContainerObject < ActiveFedora::Base
    #
    #   directly_contains :files, has_member_relation: RDFVocabularies::PCDMTerms.hasFile,
    #     class_name: "Hydra::PCDM::File"
    #
    #   def original_file
    #     file_of_type(::RDF::URI("http://pcdm.org/OriginalFile"))
    #   end
    #
    #   def thumbnail
    #     file_of_type(::RDF::URI("http://pcdm.org/ThumbnailImage"))
    #   end
    # end
    class DirectContainerObject < Hydra::Works::GenericFile::Base
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
      Hydra::Works::AddFileToGenericFile.call(object, file_path, type_uri) # attaches the file as a directly contained object
    end
    it "retrieves the file from the specified location on the given object" do
      expect(object.filter_files_by_type(type_uri).first.content).to start_with("%PDF-1.4")
    end
  end
  
end