# frozen_string_literal: true

module Studitemps
  module Utils
    module URI
      # URI base class.
      # @abstract
      class Base
        class InvalidURI < StandardError; end
        extend Dry::Core::ClassAttributes

        include Dry::Equalizer(:schema, :context, :resource, :id)

        defines :schema
        defines :context
        defines :resource
        defines :id

        # @!parse
        #   # Regular expression which the string representation of the URI has to match.
        #   #   `value` - matches the exact value
        #   #   `enum` - matches any of the given values
        #   REGEX = /\A(?<schema>`value`)\:(?<context>`value`)(:(?<resource>`enum`)(:(?<id>`enum`))?)?\z/

        # Returns string representation of URI.
        #
        # @example
        #   ExampleURI = Studitemps::Utils::URI.build(schema: 'com.example')
        #   uri = ExampleURI.new(context: 'billing', resource: 'invoice', id: 'R422342')
        #   uri.to_s # => 'com.example:billing:invoice:R422342'
        #
        # @return [String] string representation of URI
        def to_s
          [schema, context, resource, id].compact.join(':')
        end
        alias to_str to_s

        # Nicer inspect for URI.
        #
        # @return [String] inspect of URI
        def inspect
          "#<#{self.class.name} '#{self}'>"
        end

        class << self
          # Build a new URI from the given value.
          #
          # @example
          #   ExampleURI = Studitemps::Utils::URI.build(schema: 'com.example')
          #   uri = ExampleURI.new(context: 'billing', resource: 'invoice', id: 'R422342')
          #
          #   ExampleURI.build(uri)
          #   # => #<ExampleURI 'com.example:billing:invoice:R422342'>
          #   ExampleURI.build(context: 'billing', resource: 'invoice', id: 'R422342')
          #   # => #<ExampleURI 'com.example:billing:invoice:R422342'>
          #   ExampleURI.build('com.example:billing:invoice:R422342')
          #   # => #<ExampleURI 'com.example:billing:invoice:R422342'>
          #
          #   # Appropriate URIs can be cast
          #   BillingURI =  Studitemps::Utils::URI.build(from: ExampleURI, context: 'billing')
          #   BillingURI.build(uri) # => #<BillingURI 'com.example:billing:invoice:R422342'>
          #
          #   PayrollURI = Studitemps::Utils::URI.build(from: ExampleURI, context: 'payroll')
          #   PayrollURI.build(uri) # => raises Studitemps::Utils::URI::Base::InvalidURI
          #
          # @raise [InvalidURI] if value can not be converted to URI
          # @param [Base, Hash, String] value to build URI from
          # @return [Base] new URI from given value
          def build(value)
            case value
            when ::Studitemps::Utils::URI::Base then from_uri(value)
            when Hash then from_hash(value)
            when String then from_string(value)
            else
              raise Studitemps::Utils::URI::Base::InvalidURI, value.inspect
            end
          end

          private

          def from_uri(value)
            if value.is_a? self
              value
            else
              from_string(value.to_s)
            end
          end

          def from_hash(hash)
            new(**hash)
          end

          def from_string(string)
            match = string.match self::REGEX
            raise Studitemps::Utils::URI::Base::InvalidURI, "#{string.inspect} is no #{name} URI." unless match

            from_hash(schema: match[:schema], context: match[:context], resource: match[:resource], id: match[:id])
          end
        end

      end
    end
  end
end
