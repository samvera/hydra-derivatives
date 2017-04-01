module Hydra::Derivatives
  class UriSourceFileService
    # Retrieves the source
    # @param [ActiveFedora::Base] object the source file is attached to
    # @param [Hash] options
    # @option options [Symbol] :source a method that can be called on the object to retrieve the source file
    # @yield [Tempfile] a temporary source file that has a lifetime of the block
    def self.call(object, options, &block)
      source_name = options.fetch(:source)
      yield(object.send(source_name).uri.to_s)
    end
  end
end
