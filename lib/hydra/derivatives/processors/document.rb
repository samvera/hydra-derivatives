module Hydra::Derivatives::Processors
  class Document < Processor
    include ShellBasedProcessor

    def self.encode(path, options, output_file)
      format = File.extname(output_file).sub('.', '')
      outdir = File.dirname(output_file)
      execute "#{Hydra::Derivatives.libreoffice_path} --invisible --headless --convert-to #{format} --outdir #{outdir} #{path}"
    end

    def encode_file(file_suffix, options = { })
      new_output = ''
      if file_suffix == 'jpg'
        temp_file = File.join(Hydra::Derivatives.temp_file_base, [directives.fetch(:label).to_s, 'pdf'].join('.'))
        new_output = File.join(Hydra::Derivatives.temp_file_base, [File.basename(temp_file).sub(File.extname(temp_file), ''), file_suffix].join('.'))
        self.class.encode(source_path, options, temp_file)
        self.class.encode(temp_file, options, output_file(file_suffix))
        File.unlink(temp_file)
      else
        self.class.encode(source_path, options, output_file(file_suffix))
        new_output = File.join(Hydra::Derivatives.temp_file_base, [directives.fetch(:label).to_s, file_suffix].join('.'))
      end
      out_file = File.open(new_output, "rb")
      output_file_service.call(out_file, directives)
      File.unlink(out_file)
    end
  end
end
