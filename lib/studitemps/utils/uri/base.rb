# frozen_string_literal: true

module Studitemps
  module Utils
    module URI
      class Base
        class InvalidURI < StandardError; end
        extend Dry::Core::ClassAttributes

        include Dry::Equalizer(:schema, :context, :resource, :id)

        defines :schema
        defines :context
        defines :resource

        def to_s
          [schema, context, resource, id].compact.join(':')
        end
        alias to_str to_s

        def inspect
          "#<#{self.class.name} '#{self}'>"
        end

        class << self
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
