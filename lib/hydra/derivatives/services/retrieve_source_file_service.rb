module Hydra::Derivatives
  class RetrieveSourceFileService

    # Retrieves the source
    # @param [Object] object the source file is attached to
    # @param [String] method name that can be called on object to retrieve the source file

    def self.call(object, source_name)
      object.send(source_name)
    end
  end
end