module Hydra::Derivatives
  class PersistOutputFileService

    # Persists the file within the object at destination_name.  Uses basic containment.
    # If you want to use direct containment (ie. with PCDM) you must use a different service (ie. Hydra::Works::AddFileToGenericFile Service)
    # @param [Object] object the source file is attached to
    # @param [File] filestream to be added
    # @param [String] destination_name path to file
    # @option opts Specific implementations can use this as needed

    def self.call(object, file, destination_name, opts={})
      raise NotImplementedError, "PersistOutputFileService is an abstract class. Implement `call' on #{self.class.name}"
    end
  end
end