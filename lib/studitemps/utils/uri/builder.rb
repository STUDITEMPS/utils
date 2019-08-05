# frozen_string_literal: true

module Studitemps
  module Utils
    module URI
      # Builds new URI classes.
      class Builder
        extend Dry::Core::ClassAttributes

        defines :extensions

        extensions []

        # Builds a new URI class from the given parameters.
        #
        # @param [String, nil] schema the schema part of the new URI
        # @param [String, nil] context the context part of the new URI
        # @param [String, nil] resource the resource part of the new URI
        # @param [String] superclass uri base class
        # @return [Base] the new URI class
        #
        # @note Use {URI.build} instead to create new URI classes
        # @api private
        def call(schema: nil, context: nil, resource: nil, superclass: ::Studitemps::Utils::URI::Base)
          raise ArgumentError, 'missing schema' if superclass == ::Studitemps::Utils::URI::Base && schema.nil?

          klass = build_class(superclass)
          configure_class(klass, schema, context, resource)
          build_regex(klass)
          build_initializer(klass)
          run_extensions(klass)
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

        def build_initializer(klass) # rubocop:disable Metrics/AbcSize
          klass.class_eval do
            include Dry::Initializer[undefined: false].define -> {
              option :schema, proc(&:to_s), optional: false, default: -> { klass.schema }
              option :context, proc(&:to_s), optional: true, default: -> { klass.context }
              option :resource, proc(&:to_s), optional: true, default: -> { klass.resource }
              option :id, proc(&:to_s), optional: true
            }
          end
        end

        def run_extensions(klass)
          self.class.extensions.each { |extension| extension.call(klass) }
        end
      end
    end
  end
end
