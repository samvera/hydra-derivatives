module Hydra::Derivatives
  class RetrieveSourceFileService

    def self.call(object, source_name)
      object.send(source_name)
    end
  end
end