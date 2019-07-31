# frozen_string_literal: true

module Studitemps
  module Utils
    module URI
      module Extensions
        module Serialization
          module ClassMethods
            include Dry::Core::Constants

            def dump(object)
              object.to_s
            end

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
