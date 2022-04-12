module Hydra::Derivatives
  class ValkyrieSourceFileService
    # Retrieves the source
    # @param [#to_s] path to the source file
    # @param [Hash] options
    def self.call(path, _options, &_block)
      File.open(path.to_s) do |f|
        yield(f)
      end
    end
  end
end
