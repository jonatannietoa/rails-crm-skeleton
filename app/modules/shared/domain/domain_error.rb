module Shared
  module Domain
    # Root of the domain error hierarchy. Handlers raise these; the base
    # ApplicationController maps each subclass to an HTTP status.
    class DomainError < StandardError; end

    # The caller sent data the domain considers invalid (-> 422).
    class InvalidInputError < DomainError; end

    # A business invariant would be violated by the operation (-> 409).
    class BusinessRuleError < DomainError; end

    # A referenced aggregate does not exist (-> 404).
    class NotFoundError < DomainError; end
  end
end
