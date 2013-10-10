require 'hydra-file_characterization'
module Hydra
  module Derivatives
    module ExtractMetadata

      def extract_metadata
        return unless has_content?
        Hydra::FileCharacterization.characterize(content, filename_for_characterization, :fits) do |config|
          config[:fits] = Hydra::Derivatives.fits_path
        end
      end

      protected

      def filename_for_characterization
        mime_type = MIME::Types[mimeType].first
        logger.warn "Unable to find a registered mime type for #{mimeType.inspect} on #{pid}" unless mime_type
        extension = mime_type ? ".#{mime_type.extensions.first}" : ''
        "#{pid}-#{dsVersionID}#{extension}"
      end

    end
  end
end
