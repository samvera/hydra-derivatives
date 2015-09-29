module Hydra::Derivatives
  class RetrieveSourceFileService

    # Retrieves the source
    # @param [Object] object the source file is attached to
    # @param [String] method name that can be called on object to retrieve the source file
    # @yield [Tempfile] a temporary source file that has a lifetime of the block
    def self.call(object, source_name, &block)
      Hydra::Derivatives::TempfileService.create(object.send(source_name), &block)
    end
  end
end
