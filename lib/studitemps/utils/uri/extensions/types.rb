# frozen_string_literal: true

require 'dry-types'

module Studitemps
  module Utils
    module URI
      module Extensions
        # Adds dry types to URI class. These types can be used in dry struct attributes etc.
        #
        # @example
        #   require 'studitemps/utils/uri/extensions/types'
        #   MyURI = Studitemps::Utils::URI.build(schema: 'com.example')
        #   uri = MyURI.new(context: 'billing', resource: 'invoice', id: 42)
        #
        #   MyURI::Types::URI[uri] # => #<MyURI 'com.example:billing:invoice:42'>
        #   MyURI::Types::URI['com.example:billing:invoice:42'] # => #<MyURI 'com.example:billing:invoice:42'>
        #
        #   MyURI::Types::String[uri] # => 'com.example:billing:invoice:42'
        #   MyURI::Types::String['com.example:billing:invoice:42'] # => 'com.example:billing:invoice:42'
        #
        #   # Replacement for existing types
        #   module Types
        #     include Dry.Types
        #
        #     URI = ::MyURI::Types::URI
        #   end
        module Types
          ::Studitemps::Utils::URI::Builder.extensions << -> (klass) {
            types = Module.new
            types.const_set 'URI', Dry.Types.Constructor(klass) { |value| klass.build(value) }
            types.const_set 'String', Dry.Types.Constructor(klass) { |value| klass.build(value).to_s }
            klass.const_set 'Types', types
          }
        end
      end
    end
  end
end

