module Hydra::Derivatives
  class PersistOutputFileService

    # Persists the file within the object at destination_name.  Uses indirect containment.
    # If you want to use direct containment (ie. with PCDM) you must use a different service (ie. Hydra::Works::AddFileToGenericFile Service)
    def self.call(object, file, destination_name, opts={})
      raise NotImplementedError, "PersistOutputFileService is an abstract class. Implement `call' on #{self.class.name}"
    end
  end
end