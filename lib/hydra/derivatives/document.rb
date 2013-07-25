module Hydra
  module Derivatives
    class Document < Processor
      include ShellBasedProcessor
      def self.encode(path, options, output_file)
        format = File.extname(output_file).sub('.', '')
        outdir = File.dirname(output_file)
        execute "#{Hydra::Derivatives.libreoffice_path} --invisible --headless --convert-to #{format} --outdir #{outdir} #{path}"
      end

      def encode_datastream(dest_dsid, file_suffix, mime_type, options = '')
        output_file = Dir::Tmpname.create(['sufia', ".#{file_suffix}"], Hydra::Derivatives.temp_file_base){}
        new_output = ''
        source_datastream.to_tempfile do |f|
          self.class.encode(f.path, options, output_file)
          new_output = File.join(Hydra::Derivatives.temp_file_base, [File.basename(f.path).sub(File.extname(f.path), ''), file_suffix].join('.'))
        end
        out_file = File.open(new_output, "rb")
        object.add_file_datastream(out_file.read, :dsid=>dest_dsid, :mimeType=>mime_type)
        File.unlink(out_file)
      end


      def new_mime_type(format)
        case format
        when 'pdf'
          'application/pdf'
        when 'odf'
          'application/vnd.oasis.opendocument.text'
        else
          raise "I don't know about the format '#{format}'"
        end
      end
    end
  end
end
