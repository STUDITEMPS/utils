# frozen_string_literal: true

require 'base64'

module Studitemps
  module Utils
    module URI
      module Extensions
        # Adds base64 encoding and decoding functionality to URIs.
        #
        # @example
        #   require 'studitemps/utils/uri/extensions/base64'
        #   MyURI = Studitemps::Utils::URI.build(schema: 'com.example')
        #   uri = MyURI.new(context: 'billing', resource: 'invoice', id: 42)
        #
        #   uri.to_base64 # => 'Y29tLmV4YW1wbGU6YmlsbGluZzppbnZvaWNlOjQy'
        #   MyURI.from_base64('Y29tLmV4YW1wbGU6YmlsbGluZzppbnZvaWNlOjQy') # => #<MyURI 'com.example:billing:invoice:42'>
        module Base64Encoding

          # Included instance methods.
          module InstanceMethods
            # Returns the base64 encoded URI.
            def to_base64
              Base64.strict_encode64(to_s)
            end
          end

          # Extended class methods.
          module ClassMethods
            # Builds URI from base64 encoded string.
            #
            # @param base64_encoded_string [String] the base64 encoded URI
            # @return [Base] the new URI.
            def from_base64(base64_encoded_string)
              from_string(Base64.strict_decode64(base64_encoded_string))
            end
          end

          ::Studitemps::Utils::URI::Base.include(InstanceMethods)
          ::Studitemps::Utils::URI::Base.extend(ClassMethods)
        end
      end
    end
  end
end
