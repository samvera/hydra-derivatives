require 'spec_helper'

describe Hydra::Derivatives::Jpeg2kImage do
  let(:object) { ActiveFedora::Base.new }

  describe "#calculate recipe" do
    it "calculates the number of levels from a size" do
      dim = 7200
      Hydra::Derivatives::Jpeg2kImage.level_count_for_size(dim).should == 6
    end

    it "calculates the compression rates for each quality layer" do
      compression_num = 10
      layers = 8
      calc = Hydra::Derivatives::Jpeg2kImage.layer_rates(layers, compression_num) 
      calc.should == "2.4,1.48331273,0.91675694,0.56659885,0.3501847,0.21643059,0.13376427,0.0826726"
    end
  end

end
