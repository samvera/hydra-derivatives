require 'spec_helper'
require 'hydra/works'

describe Hydra::Derivatives::PersistIndirectlyContainedOutputFile do

  before(:all) do
    class IndirectContainerObject < ActiveFedora::Base
      contains "the_derivative_name"
    end

    # This uses directly_contains (inherited from Hydra::PCDM::ObjectBehavior)
    class DirectContainerObject < Hydra::Works::GenericFile::Base
    end
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
  end

  let(:object)            { IndirectContainerObject.new  }
  let(:file_path)         { File.join(fixture_path, 'test.tif') }
  let(:file)              { File.new(file_path)}
  let(:destination_name)  { 'the_derivative_name' }

  context "when file is indirectly contained (default assumption)" do  # alas, we have to support this as the default because all legacy code (and fedora 3 systems) created indirectly contained files
    let(:object)            { IndirectContainerObject.new  }
    it "persists the file to the specified destination on the given object" do
      described_class.call(object, "fake file content", destination_name)
      expect(object.send(destination_name.to_sym).content).to eq("fake file content")
      expect(object.send(destination_name.to_sym).content_changed?).to eq false
    end
  end

end