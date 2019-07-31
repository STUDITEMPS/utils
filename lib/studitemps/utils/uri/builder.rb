# frozen_string_literal: true

module Studitemps
  module Utils
    module URI
      class Builder
        def call(schema: nil, context: nil, resource: nil, superclass: ::Studitemps::Utils::URI::Base)
          raise ArgumentError, 'missing schema' if superclass == ::Studitemps::Utils::URI::Base && schema.nil?

          klass = build_class(superclass)
          configure_class(klass, schema, context, resource)
          build_regex(klass)
          build_initializer(klass)
          klass
        end

        private

        def build_class(superclass)
          Class.new(superclass)
        end

        def configure_class(klass, new_schema, new_context, new_resource)
          klass.class_eval do
            schema new_schema if new_schema
            context new_context if new_context
            resource new_resource if new_resource
          end
        end

        def build_regex(klass, default: '[\w\-_]+')
          schema = Regexp.escape(klass.schema)
          context = klass.context ? Regexp.escape(klass.context) : default
          resource = klass.resource ? Regexp.escape(klass.resource) : default
          regex = /\A
            (?<schema>#{schema})\:
            (?<context>#{context})
            (:(?<resource>#{resource})
            (:(?<id>.*))?)?
          \z/x
          klass.const_set('REGEX', regex.freeze)
        end

        def build_initializer(klass)
          klass.class_eval do
            include Dry::Initializer[undefined: false].define -> {
              option :schema, optional: false, default: -> { klass.schema }
              option :context, optional: true, default: -> { klass.context }
              option :resource, optional: true, default: -> { klass.resource }
              option :id, optional: true
            }
          end
        end
      end
    end
  end
end
