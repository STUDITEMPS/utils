# frozen_string_literal: true

require 'dry/core/deprecations'

module Studitemps
  module Utils
    module URI
      module Extensions
        # Adds deprecated aliases to URI for legacy usage.
        #
        # @example
        #   require 'studitemps/utils/uri/extensions/aliases'
        #   klass = Studitemps::Utils::URI.build(schema: 'com.example')
        #   uri = klass.new(context: 'billing', resource: 'invoice', id: 42)
        #
        #   uri.resource_type # => 'invoice'
        #   uri.resource_id # => '42'
        module Aliases

          # Included instance methods.
          module InstanceMethods
            extend Dry::Core::Deprecations['URI Aliases']

            # Returns the `resource`.
            #
            # @deprecated Use {Studitemps::Utils::URI::Base#resource} instead
            def resource_type
              resource
            end
            deprecate :resource_type, message: 'Use Base#resource instead.'

            # Returns the `id`.
            #
            # @deprecated Use {Studitemps::Utils::URI::Base#id} instead.
            def resource_id
              id
            end
            deprecate :resource_id, message: 'Use Base#id instead.'
          end

          ::Studitemps::Utils::URI::Base.include(InstanceMethods)
        end
      end
    end
  end
end
