module Customers
  # A customer synced from a CRM, scoped to nothing more than its own identity
  # in this skeleton. It owns its CRM metadata as a value object; the aggregate
  # guards its invariants (a name is required) and never touches persistence.
  class Customer < Shared::AggregateRoot
    attr_reader :name, :email, :metadata, :created_at, :updated_at

    def self.register(name:, email:, metadata:, now:)
      name = name.to_s.strip
      raise Shared::InvalidInputError, "The customer name is required." if name.empty?

      new(
        id: Shared::AggregateRoot.new_id,
        name: name,
        email: email,
        metadata: metadata,
        created_at: now,
        updated_at: now,
      )
    end

    def self.rehydrate(id:, name:, email:, metadata:, created_at:, updated_at:)
      new(
        id: id,
        name: name,
        email: email,
        metadata: metadata,
        created_at: created_at,
        updated_at: updated_at,
      )
    end

    def initialize(id:, name:, email:, metadata:, created_at:, updated_at:)
      super(id)
      @name = name
      @email = email
      @metadata = metadata
      @created_at = created_at
      @updated_at = updated_at
    end
  end
end
