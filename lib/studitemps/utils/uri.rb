# frozen_string_literal: true

require 'dry/core/class_attributes'
require 'dry/core/extensions'
require 'dry-initializer'
require 'dry-equalizer'

require_relative 'uri/builder'
require_relative 'uri/base'

module Studitemps
  module Utils
    ##
    # Studitemps URI
    #
    # @since 0.1.0
    module URI

      module_function

      ##
      # Build a new Studitemps URI class from some base class.
      #
      # @param schema [String] URI schema
      # @param context [String] URI context
      # @param resource [String] URI resrouce
      # @param from [Base] superclass to use
      # @return [Base] the new URI class
      #
      # @example Basic usage
      #  require 'studitemps/utils/uri'
      #
      #  ExampleURI = Studitemps::Utils::URI.build(schema: 'com.example')
      #
      #  ExampleURI.new # => #<ExampleURI 'com.example'>
      #
      #  uri = ExampleURI.new(context: 'billing', resource: 'invoice', id: 'R422342')
      #  # => #<ExampleURI 'com.example:billing:invoice:R422342'>
      #
      #  uri.to_s # => 'com.example:billing:invoice:R422342'
      #
      #  ExampleURI.build('com.example:billing:invoice:R422342')
      #  # => #<ExampleURI 'com.example:billing:invoice:R422342'>
      def build(schema: nil, context: nil, resource: nil, id: nil, from: Base)
        Builder.new.call(schema: schema, context: context, resource: resource, id: id, superclass: from)
      end
    end
  end
end
