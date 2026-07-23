module Shared
  # A business invariant would be violated by the operation (-> 409).
  class BusinessRuleError < DomainError; end
end
