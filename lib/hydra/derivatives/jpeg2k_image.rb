require 'mini_magick'
require 'nokogiri'
module Hydra
  module Derivatives
    class Jpeg2kImage < Processor 
      include ShellBasedProcessor

      def process
        quality, colorspace = extract_quality_and_colorspace
        directives.each do |name, args|
          file_path = nil
          long_dim = nil
          to_srgb = args.fetch(:to_srgb, true)
          if args[:resize] || to_srgb
            image = preprocess(resize: args[:resize], to_srgb: to_srgb, src_quality: quality)
            long_dim = self.class.long_dim(image)
            file_path = self.class.tmp_file('.tif')
            image.write file_path
          else
            long_dim = self.class.long_dim(MiniMagick::Image.read(source_datastream.content))
          end
          recipe = self.class.kdu_compress_recipe(args, quality, long_dim)
          output_datastream_name = args[:datastream] || output_datastream_id(name)
          encode_datastream(output_datastream_name, recipe, file_path: file_path)
          File.unlink(file_path) unless file_path.nil?
        end
      end

      def encode_datastream(dest_dsid, recipe, opts={})
        output_file = self.class.tmp_file('.jp2')
        if opts[:file_path]
          self.class.encode(opts[:file_path], recipe, output_file)
        else
          source_datastream.to_tempfile do |f|
            self.class.encode(f.path, recipe, output_file)
          end
        end
        out_file = File.open(output_file, "rb")
        object.add_file_datastream(out_file.read, dsid: dest_dsid, mimeType: 'image/jp2')
        File.unlink(output_file)
      end
      
      protected
      def preprocess(opts={})
        # resize: <geometry>, to_srgb: <bool>,src_quality: 'color'|'grey'
        image = MiniMagick::Image.read(source_datastream.content)
        image.combine_options do |c|
          c.resize(opts[:resize]) if opts[:resize]
          c.profile self.class.srgb_profile_path if opts[:src_quality] == 'color' && opts[:to_srgb]
        end
        image
      end

      def extract_quality_and_colorspace
        xml = source_datastream.extract_metadata
        doc = Nokogiri::XML(xml).remove_namespaces!
        bps = doc.xpath('//bitsPerSample').first.content
        quality = bps == '8 8 8' ? 'color' : 'grey'
        colorspace = doc.xpath('.//colorSpace').first.content
        [quality, colorspace]
      end

      def self.encode(path, recipe, output_file)
        kdu_compress = Hydra::Derivatives.kdu_compress_path
        execute "#{kdu_compress} -i #{path} -o #{output_file} #{recipe}"
      end

      def self.srgb_profile_path
        File.join [
          File.expand_path('../../../', __FILE__),
          'color_profiles', 
          'sRGB_IEC61966-2-1_no_black_scaling.icc'
        ]
      end

      def self.tmp_file(ext)
        Dir::Tmpname.create(['sufia', ext], Hydra::Derivatives.temp_file_base){}
      end

      def self.long_dim(image)
        [image[:width], image[:height]].max
      end

      def self.kdu_compress_recipe(args, quality, long_dim)
        if args[:recipe].is_a? Symbol
          recipe = [args[:recipe].to_s, quality].join('_').to_sym
          if Hydra::Derivatives.kdu_compress_recipes.has_key? recipe
            return Hydra::Derivatives.kdu_compress_recipes[recipe]
          else
            logger.warn "No JP2 recipe for #{args[:recipe].to_s} found in configuration. Using best guess."
            return calcuate_recipe(args,quality,long_dim)
          end
        elsif args[:recipe].is_a? String
          return args[:recipe]
        else
          return calculate_recipe(args,quality,long_dim)
        end
      end

      def self.calculate_recipe(args, quality, long_dim)
        levels_arg = args.fetch(:levels, level_count_for_size(long_dim))
        rates_arg = layer_rates(args.fetch(:layers, 8), args.fetch(:compression, 10))
        tile_size = args.fetch(:tile_size, 1024)
        tiles_arg = "\{#{tile_size},#{tile_size}\}"
        jp2_space_arg = quality == 'grey' ? 'sLUM' : 'sRGB'

        %Q{-rate #{rates_arg} 
            -jp2_space #{jp2_space_arg}
            -double_buffering 10 
            -num_threads 4 
            -no_weights 
            Clevels=#{levels_arg} 
            Stiles=#{tiles_arg}
            Cblk=\{64,64\} 
            Cuse_sop=yes 
            Cuse_eph=yes  
            Corder=RPCL 
            ORGgen_plt=yes 
            ORGtparts=R  }.gsub(/\s+/, " ").strip
      end

      def self.level_count_for_size(long_dim)
        levels = 0
        level_size = long_dim
        while level_size >= 96
          level_size = level_size/2
          levels+=1
        end
        levels-1
      end

      def self.layer_rates(layer_count,compression_numerator)
        #e.g. if compression_numerator = 10 then compression is 10:1
        rates = []
        cmp = 24.0/compression_numerator
        layer_count.times do
          rates << cmp
          cmp = (cmp/1.618).round(8)
        end
        rates.map(&:to_s ).join(',')
      end

    end
  end
end
