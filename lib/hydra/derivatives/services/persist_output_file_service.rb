module Hydra::Derivatives
  class PersistOutputFileService

    # Persists the file within the object at destination_name.  Uses basic containment.
    # If you want to use direct containment (ie. with PCDM) you must use a different service (ie. Hydra::Works::AddFileToGenericFile Service)
    # @param [Object] object the source file is attached to
    # @param [File] filestream to be added, should respond to :mime_type, :original_name
    # @param [String] destination_name is the fedora path at which the child resource will be found or created beneath the object.

    def self.call(object, file, destination_path)
      raise NotImplementedError, "PersistOutputFileService is an abstract class. Implement `call' on #{self.class.name}"
    end

    def self.determine_original_name( file )
      if file.respond_to? :original_name
         file.original_name
       else
         "derivative"
       end
    end

    def self.determine_mime_type( file )
      if file.respond_to? :mime_type
         file.mime_type
       else
         "appliction/octet-stream"
       end
    end

  end
end
