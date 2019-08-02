# frozen_string_literal: true

require 'base64'

module Studitemps
  module Utils
    module URI
      module Extensions
        # Allows URIs to be compared to strings.
        #
        # @example
        #   MyURI = Studitemps::Utils::URI.build(schema: 'com.example')
        #   uri = MyURI.new(context: 'billing', resource: 'invoice', id: 42)
        #   uri == 'com.example:billing:invoice:42' # => true
        module StringEquality

          # Included instance methods.
          module InstanceMethods

            # Compares other with own string representation if other is a string.
            #
            # @param other [String] string to compare own string representation with.
            # @return [Boolean] if own string representation equals other
            def eql?(other)
              other.is_a?(String) ? to_s.eql?(other) : super
            end

            # Compares other with own string representation if other is a string.
            #
            # @param other [String] string to compare own string representation with.
            # @return [Boolean] if own string representation equals other
            def ==(other)
              other.is_a?(String) ? to_s == other : super
            end
          end

          ::Studitemps::Utils::URI::Base.include(InstanceMethods)
        end
      end
    end
  end
end
