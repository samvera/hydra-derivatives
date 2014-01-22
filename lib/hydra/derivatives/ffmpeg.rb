# An abstract class for asyncronous jobs that transcode files using FFMpeg

require 'tmpdir'
require 'streamio-ffmpeg'

module Hydra
  module Derivatives
    module Ffmpeg
      extend ActiveSupport::Concern

        def process
          directives.each do |name, args| 
            format = args[:format]
            raise ArgumentError, "You must provide the :format you want to transcode into. You provided #{args}" unless format
            # TODO if the source is in the correct format, we could just copy it and skip transcoding.
            output_datastream_name = args[:datastream] || output_datastream_id(name)
            options = args.reject {|k, v| [:format, :datastream].include? k }
            options = {custom: options_for(format)} if options.empty?
            encode_datastream(output_datastream_name, format, new_mime_type(format), options)
          end
        end

        # override this method in subclass if you want to provide specific options.
        def options_for(format)
        end

        def encode_datastream(dest_dsid, file_suffix, mime_type, options)
          out_file = nil
          output_file = Dir::Tmpname.create(['sufia', ".#{file_suffix}"], Hydra::Derivatives.temp_file_base){}
          source_datastream.to_tempfile do |f|
            encode(f.path, options, output_file)
          end
          out_file = File.open(output_file, "rb")
          object.add_file_datastream(out_file.read, :dsid=>dest_dsid, :mimeType=>mime_type)
          File.unlink(output_file)
        end

        def encode(path, options, output_file)
          movie = FFMPEG::Movie.new(path)
          movie.transcode(output_file, options)
        end

    end
  end
end

