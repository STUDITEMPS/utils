# frozen_string_literal: true

require 'base64'

module Studitemps
  module Utils
    module URI
      module Extensions
        module StringEquality

          module InstanceMethods
            def eql?(other)
              other.is_a?(String) ? to_s.eql?(other) : super
            end

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
