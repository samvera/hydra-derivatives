module Hydra::Derivatives::Processors
  # Extract the full text from the content using Solr's extract handler
  class FullText < Processor
    # Run the full text extraction and save the result
    # @return [TrueClass,FalseClass] was the process successful.
    def process
      output_file_service.call(extract, directives)
    end

    private

      ##
      # Extract full text from the content using Solr's extract handler.
      # This will extract text from the file
      #
      # @return [String] The extracted text
      def extract
        JSON.parse(fetch)[''].rstrip
      end

      # send the request to the extract service and return the response if it was successful.
      # TODO: this pulls the whole file into memory. We should stream it from Fedora instead
      # @return [String] the result of calling the extract service
      def fetch
        req = Net::HTTP.new(uri.host, uri.port)
        req.use_ssl = true if check_for_ssl
        resp = req.post(uri.to_s, file_content, request_headers)
        raise "Solr Extract service was unsuccessful. '#{uri}' returned code #{resp.code} for #{source_path}\n#{resp.body}" unless resp.code == '200'
        file_content.rewind if file_content.respond_to?(:rewind)

        if resp.type_params['charset']
          resp.body.force_encoding(resp.type_params['charset'])
        end
        resp.body
      end

      def file_content
        @content ||= File.open(source_path).read
      end

      # @return [Hash] the request headers to send to the Solr extract service
      def request_headers
        { Faraday::Request::UrlEncoded::CONTENT_TYPE => mime_type.to_s,
          Faraday::Adapter::CONTENT_LENGTH => original_size.to_s }
      end

      def mime_type
        Hydra::Derivatives::MimeTypeService.mime_type(source_path)
      end

      def original_size
        File.size(source_path)
      end

      # @returns [URI] path to the extract service
      def uri
        @uri ||= connection_url + 'update/extract?extractOnly=true&wt=json&extractFormat=text'
      end

      def check_for_ssl
        uri.scheme == 'https'
      end

      # @returns [URI] path to the solr collection
      def connection_url
        ActiveFedora::SolrService.instance.conn.uri
      end
  end
end
