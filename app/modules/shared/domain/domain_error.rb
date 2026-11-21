module Shared
  # Root of the domain error hierarchy. Handlers raise these; the base
  # ApplicationController maps each subclass to an HTTP status. Each subclass
  # lives in its own file so Zeitwerk can autoload it by name.
  class DomainError < StandardError; end
end
