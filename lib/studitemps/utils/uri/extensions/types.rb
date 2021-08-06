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
      # values (enum if URI builder is provided with an array as the argument). `id` also supports regular expressions.
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
          value_type(klass.schema)
        end

        def context_type(klass)
          value_type(klass.context)
        end

        def resource_type(klass)
          enum_type(klass.resource)
        end

        def id_type(klass)
          dynamic_type(klass.id)
        end

        def dynamic_type(value)
          case value
          when Array then enum_type(value)
          when String, Symbol then value_type(value)
          when Regexp then regexp_type(value)
          else
            default_type
          end
        end

        def value_type(value)
          return default_type unless value

          Dry.Types::Value(value)
        end

        def enum_type(value)
          return default_type unless value

          Dry.Types::Strict::String.enum(*Array(value))
        end

        def regexp_type(value)
          return default_type unless value

          Dry.Types::Strict::String.constrained(format: value)
        end
      end
    end
  end
end

