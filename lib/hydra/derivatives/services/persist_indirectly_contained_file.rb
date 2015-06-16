module Hydra::Derivatives
  # This Service is an implementation of the Hydra::Derivatives::PeristOutputFileService
  # It supports indirectly contained files, which is the behavior associated with Fedora 3 file datastreams that were migrated to Fedora 4
  # and, at the time that this class was authored, corresponds to the behavior of ActiveFedora::Base.attach_file and ActiveFedora::Base.attached_files
  class PersistIndirectlyContainedOutputFile < PersistOutputFileService

    # This method conforms to the signature of the .call method on Hydra::Derivatives::PeristOutputFileService
    # * Persists the file within the object at destination_name
    #
    # NOTE: Uses indirect containment. If you want to use direct containment (ie. with PCDM) you must use a different service (ie. Hydra::Works::AddFileToGenericFile Service)
    #

    def self.call(object, file, destination_name, opts={})
      # first, check for a defined file
      # if object.attached_files[destination_name]
      #   output_file = object.attached_files[destination_name]
      #   output_file.content = file
      # else
      #   output_file = ActiveFedora::File.new("#{object.uri}/#{destination_name}").tap do |file|
      #     object.attach_file(file, destination_name)
      #   end
      # end
      # output_file.mime_type = opts[:mime_type] if opts[:mime_type]

      object.add_file(file, path: destination_name, mime_type: opts[:mime_type])
      object.save
    end
  end
end