# frozen_string_literal: true

require 'base64'

module Studitemps
  module Utils
    module URI
      module Extensions
        module Base64Encoding

          module InstanceMethods
            def to_base64
              Base64.strict_encode64(to_s)
            end
          end

          module ClassMethods
            def from_base64(base64_encoded_string)
              from_string(Base64.strict_decode64(base64_encoded_string))
            end
          end

          ::Studitemps::Utils::URI::Base.include(InstanceMethods)
          ::Studitemps::Utils::URI::Base.extend(ClassMethods)
        end
      end
    end
  end
end
