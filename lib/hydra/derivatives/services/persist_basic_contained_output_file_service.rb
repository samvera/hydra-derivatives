module Hydra::Derivatives
  # This Service is an implementation of the Hydra::Derivatives::PeristOutputFileService
  # It supports basic contained files, which is the behavior associated with Fedora 3 file datastreams that were migrated to Fedora 4
  # and, at the time that this class was authored, corresponds to the behavior of ActiveFedora::Base.attach_file and ActiveFedora::Base.attached_files
  ### Rename this
  class PersistBasicContainedOutputFileService < PersistOutputFileService

    # This method conforms to the signature of the .call method on Hydra::Derivatives::PeristOutputFileService
    # * Persists the file within the object at destination_name
    #
    # NOTE: Uses basic containment. If you want to use direct containment (ie. with PCDM) you must use a different service (ie. Hydra::Works::AddFileToGenericFile Service)
    #
    # @param [#read] stream the data to be persisted
    # @param [Hash] directives directions which can be used to determine where to persist to.
    # @option directives [String] url This can determine the path of the object.
    def self.call(stream, directives)
      file = Hydra::Derivatives::IoDecorator.new(stream, new_mime_type(directives.fetch(:format)))
      o_name = determine_original_name(file)
      m_type = determine_mime_type(file)
      uri = URI(directives.fetch(:url))
      raise ArgumentError, "#{uri} is not an http uri" unless uri.scheme == 'http'
      remote_file = ActiveFedora::File.new(uri.to_s)
      remote_file.content = file
      remote_file.mime_type = m_type
      remote_file.original_name = o_name
      remote_file.save
    end

    def self.new_mime_type(format)
      case format
      when 'mp4'
        'video/mp4' # default is application/mp4
      when 'webm'
        'video/webm' # default is audio/webm
      else
        MIME::Types.type_for(format).first.to_s
      end
    end
  end
end
