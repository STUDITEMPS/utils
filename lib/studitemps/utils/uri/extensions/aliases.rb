# frozen_string_literal: true

require 'base64'

module Studitemps
  module Utils
    module URI
      module Extensions
        module Aliases

          module InstanceMethods
            def resource_type
              resource
            end

            def resource_id
              id
            end
          end

          ::Studitemps::Utils::URI::Base.include(InstanceMethods)
        end
      end
    end
  end
end
