module Shared
  # A referenced aggregate does not exist (-> 404).
  class NotFoundError < DomainError; end
end
