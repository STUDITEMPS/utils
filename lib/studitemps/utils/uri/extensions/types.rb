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
            types.const_set 'String', Dry.Types.Constructor(String) { |value| klass.build(value).to_s }
            klass.const_set 'Types', types
          }

        end
      end

      ##
      # Adds type checks to initializer arguments.
      # `schema` and `context` values are checked and `resource` and `id` are checked against a possible list of
      # values (enum if URI builder is provided with an array as the argument).
      #
      # @example
      #   require 'studitemps/utils/uri/extensions/types'
      #   InvoiceURI = Studitemps::Utils::URI.build(
      #     schema: 'com.example', context: 'billing', resource: 'invoice', id: %w[final past_due]
      #   )
      #
      #   InvoiceURI.new(id: 'final') # => #<InvoiceURI 'com.example:billing:invoice:final'>
      #   InvoiceURI.new(id: 'pro_forma') # => Dry::Types::ConstraintError
      #
      # @since 0.2.0
      class Builder
        private

        def schema_type(klass)
          value_type(:schema, klass)
        end

        def context_type(klass)
          value_type(:context, klass)
        end

        def resource_type(klass)
          enum_type(:resource, klass)
        end

        def id_type(klass)
          enum_type(:id, klass)
        end

        def value_type(value, klass, default: default_type)
          return default unless klass.send(value)

          Dry.Types::Value(klass.send(value))
        end

        def enum_type(value, klass, default: default_type)
          return default unless klass.send(value)

          Dry.Types::Strict::String.enum(*Array(klass.send(value)))
        end
      end
    end
  end
end

