module Customers
  module Application
    # The customer as returned by the API. Read models are the only shape that
    # crosses the application boundary outwards — controllers never serialize the
    # aggregate directly, so persistence/domain internals stay hidden.
    CustomerReadModel = Data.define(:id, :name, :email, :metadata, :created_at) do
      def self.from(customer)
        new(
          id: customer.id,
          name: customer.name,
          email: customer.email.value,
          metadata: customer.metadata.to_h,
          created_at: customer.created_at.utc.iso8601,
        )
      end
    end
  end
end
