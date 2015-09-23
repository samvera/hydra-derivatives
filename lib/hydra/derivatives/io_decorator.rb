# Nieve implementation of IO wrapper class that adds mime_type and original_name attributes.
# This is done so the attributes do not have to be passed as additional arguments, 
#  and are attached properly to the object they describe.
#
#
#  Use SimpleDelegator to wrap the given class or instance
require 'delegate'

module Hydra
  module Derivatives
    class IoDecorator < SimpleDelegator
      attr_accessor :mime_type, :original_name
    end
  end
end
