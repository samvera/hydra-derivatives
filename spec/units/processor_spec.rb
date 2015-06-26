require 'spec_helper'
require 'hydra/works'

describe Hydra::Derivatives::Processor do

  before(:all) do
    class IndirectContainerObject < ActiveFedora::Base
      contains "content"
      contains "thumbnail"
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

  let(:object)        { IndirectContainerObject.new  }
  let(:source_name)   { 'content' }
  let(:directives)    { { thumb: "100x100>" } }

  subject { Hydra::Derivatives::Processor.new(object, source_name, directives)}

  describe "source_file" do
    it "retrieves the specified source" do
      expect(subject.source_file).to eq(object.content)
    end
  end

  describe "when files are directly contained by object (like files in a PCDM::Object)" do
    let(:object)        { DirectContainerObject.new }
    let(:source_name)   { 'original_file' }
    before do
      object.save
    end
    it "is able to find source_file and output_file" do
      expect(subject.source_file).to eq(object.original_file)
      expect{ subject.output_file }.to raise_error(NotImplementedError)
    end
  end

end