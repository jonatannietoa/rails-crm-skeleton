module Customers
  # Use case: create a customer together with its CRM metadata (e.g. an entity
  # synced from Affinity.co). A command is a plain value object; the handler
  # orchestrates the domain and depends only on the repository port.
  module InsertCustomerMetadata
    # `metadata` is a raw attributes hash (source, external_id, entity_type,
    # list_entry_id, fields, tags) — the value object validates it.
    Command = Data.define(:name, :email, :metadata)

    class Handler
      def initialize(customers:, clock:)
        @customers = customers
        @clock = clock
      end

      # @return [Customers::CustomerReadModel]
      def call(command)
        email = Shared::Email.create(command.email)
        if @customers.find_by_email(email.value)
          raise Shared::BusinessRuleError, "A customer with this email already exists."
        end

        metadata = CRMMetadata.create(**command.metadata)
        customer = Customer.register(
          name: command.name,
          email: email,
          metadata: metadata,
          now: @clock.now,
        )
        @customers.save(customer)

        CustomerReadModel.from(customer)
      end
    end
  end
end
