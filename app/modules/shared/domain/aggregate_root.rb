require "securerandom"

module Shared
  # Base class for aggregate roots. Owns identity generation so domain code
  # never touches persistence or SecureRandom directly. Ids are UUIDv4 strings.
  class AggregateRoot
    attr_reader :id

    def initialize(id)
      @id = id
    end

    def self.new_id
      SecureRandom.uuid
    end

    def ==(other)
      other.is_a?(self.class) && other.id == id
    end
    alias eql? ==

    def hash
      [self.class, id].hash
    end
  end
end
