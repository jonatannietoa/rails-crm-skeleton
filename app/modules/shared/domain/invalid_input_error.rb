module Shared
  # The caller sent data the domain considers invalid (-> 422).
  class InvalidInputError < DomainError; end
end
