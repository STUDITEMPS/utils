# frozen_string_literal: true

module Studitemps
  module Utils
    module URI
      module Extensions
        ##
        # Adds ActiveRecord serialization methods.
        #
        # With this an URI can be used in serializtion
        # @example
        #   MyURI = Studitemps::Utils::Uri.build(schema: 'com.example')
        #
        #   class SomeRecord < ApplicationRecord
        #     serialize :my_uri, MyURI
        #   end
        #
        # @example
        #   require 'studitemps/utils/uri/extensions/serialization'
        #   MyURI = Studitemps::Utils::URI.build(schema: 'com.example')
        #   uri = MyURI.new(context: 'billing', resource: 'invoice', id: 42)
        #
        #   MyURI.dump(uri) # => 'com.example:billing:invoice:42'
        #   MyURI.load('com.example:billing:invoice:42') # => #<MyURI 'com.example:billing:invoice:42'>
        module Serialization
          # Extended class methods.
          module ClassMethods
            include Dry::Core::Constants

            # Returns string representation of given URI.
            #
            # @param object [#to_s] URI to serialize
            # @return [String] string representation of the URI
            def dump(object)
              object.to_s
            end

            # Returns new URI object from given string.
            #
            # @param string [String] string representation of an URI
            # @return [Base, nil] the new URI
            def load(string)
              return nil if string.nil? || string == EMPTY_STRING

              from_string(string)
            end
          end

          ::Studitemps::Utils::URI::Base.extend(ClassMethods)
        end
      end
    end
  end
end
