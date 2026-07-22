module Shared
  module Domain
    module ValueObjects
      # Normalised, validated email address. Immutable value object shared across
      # bounded contexts.
      class Email
        FORMAT = /\A[^@\s]+@[^@\s]+\.[^@\s]+\z/

        attr_reader :value

        def self.create(raw)
          normalised = raw.to_s.strip.downcase
          unless FORMAT.match?(normalised)
            raise Shared::Domain::InvalidInputError, "\"#{raw}\" is not a valid email address."
          end

          new(normalised)
        end

        def initialize(value)
          @value = value
          freeze
        end

        def ==(other)
          other.is_a?(Email) && other.value == value
        end
        alias eql? ==

        def hash
          value.hash
        end

        def to_s
          value
        end
      end
    end
  end
end
