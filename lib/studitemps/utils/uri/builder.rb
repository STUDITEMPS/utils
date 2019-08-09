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
        # @param [String, [String], nil] resource the resource part of the new URI
        # @param [String, [String], nil] id the optional fixed id part of the new URI
        # @param [String] superclass uri base class
        # @return [Base] the new URI class
        #
        # @note Use {URI.build} instead to create new URI classes
        # @api private
        def call(schema: nil, context: nil, resource: nil, id: nil, superclass: ::Studitemps::Utils::URI::Base)
          raise ArgumentError, 'missing schema' if superclass == ::Studitemps::Utils::URI::Base && schema.nil?

          klass = build_class(superclass)
          configure_class(klass, schema, context, resource, id)
          build_regex(klass)
          build_initializer(klass)
          run_extensions(klass)
          klass
        end

        private

        def build_class(superclass)
          Class.new(superclass)
        end

        def configure_class(klass, new_schema, new_context, new_resource, new_id)
          klass.class_eval do
            schema new_schema if new_schema
            context new_context if new_context
            resource new_resource if new_resource
            id new_id if new_id
          end
        end

        def build_regex(klass)
          regex = /\A
            (?<schema>#{value_regex(:schema, klass)})\:
            (?<context>#{value_regex(:context, klass)})
            (:(?<resource>#{enum_regex(:resource, klass)})
            (:(?<id>#{enum_regex(:id, klass, default: '.*')}))?)?
          \z/x
          klass.const_set('REGEX', regex.freeze)
        end

        def build_initializer(klass) # rubocop:disable Metrics/AbcSize
          klass.extend Dry::Initializer[undefined: false]

          klass.option :schema, type: schema_type(klass), optional: false, default: -> { klass.schema }
          klass.option :context, type: context_type(klass), optional: true, default: -> { klass.context }
          klass.option :resource, type: resource_type(klass), optional: true,
            default: -> { Array(klass.resource).first }
          klass.option :id, type: id_type(klass), optional: true
        end

        def run_extensions(klass)
          self.class.extensions.each { |extension| extension.call(klass) }
        end

        def value_regex(value, klass, default: '[\w\-_]+')
          return default unless klass.send(value)

          Regexp.escape(klass.send(value))
        end

        def enum_regex(value, klass, default: '[\w\-_]+')
          return default unless klass.send(value)

          values = Array(klass.send(value)).map { |v| Regexp.escape(v) }
          "(#{values.join('|')})"
        end

        def default_type
          proc(&:to_s)
        end

        %i[schema context resource id].each do |attribute|
          define_method "#{attribute}_type" do |_klass|
            default_type
          end
        end
      end
    end
  end
end
