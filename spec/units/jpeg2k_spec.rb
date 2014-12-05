require 'spec_helper'
require 'yaml'

describe Hydra::Derivatives::Jpeg2kImage do
  let(:object) { ActiveFedora::Base.new }

  describe "#calculate_recipe" do
    it "calculates the number of levels from a size" do
      dim = 7200
      expect(Hydra::Derivatives::Jpeg2kImage.level_count_for_size(dim)).to eq(6)
    end

    it "calculates the compression rates for each quality layer" do
      compression_num = 10
      layers = 8
      calc = Hydra::Derivatives::Jpeg2kImage.layer_rates(layers, compression_num)
      expect(calc).to eq("2.4,1.48331273,0.91675694,0.56659885,0.3501847,0.21643059,0.13376427,0.0826726")
    end

  end

  describe "#kdu_compress_recipe" do
    before(:all) do
      @sample_cfg = YAML.load_file(File.expand_path('../../fixtures/jpeg2k_config.yml', __FILE__))['test']
      Hydra::Derivatives.kdu_compress_recipes = @sample_cfg['jp2_recipes']
    end

    it "can get the recipe from a config file" do
      args = { recipe: :myrecipe }
      r = Hydra::Derivatives::Jpeg2kImage.kdu_compress_recipe(args, 'grey', 7200)
      expect(r).to eq(@sample_cfg['jp2_recipes'][:myrecipe_grey])
    end

    it "can take a recipe as a string" do
      args = { recipe: '-my -excellent -recipe' }
      r = Hydra::Derivatives::Jpeg2kImage.kdu_compress_recipe(args, 'grey', 7200)
      expect(r).to eq(args[:recipe])
    end

    it "will fall back to a #calculate_recipe if a symbol is passed but no recipe is found" do
      args = { recipe: :x }
      r = Hydra::Derivatives::Jpeg2kImage.kdu_compress_recipe(args, 'grey', 7200)
      expect(r).to eq(Hydra::Derivatives::Jpeg2kImage.calculate_recipe(args, 'grey', 7200))
    end

    it "will fall back to a #calculate_recipe if there is no attempt to provide one" do
      args = {}
      r = Hydra::Derivatives::Jpeg2kImage.kdu_compress_recipe(args, 'grey', 7200)
      expect(r).to eq(Hydra::Derivatives::Jpeg2kImage.calculate_recipe(args, 'grey', 7200))
    end

  end

end
