require 'active_encode'

module Hydra::Derivatives::Processors
  class ActiveEncode < Processor
    def process
      ::ActiveEncode::Base.create(source_path, directives)
      # TODO wait until the encode job succeeds then call output_file_service with the output url
    end
  end
end
