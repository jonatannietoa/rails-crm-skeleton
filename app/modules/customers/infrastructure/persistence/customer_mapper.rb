module Customers
  module Infrastructure
    module Persistence
      # Translates between the Customer aggregate and its ActiveRecord row.
      module CustomerMapper
        module_function

        def to_domain(row)
          Domain::Customer.rehydrate(
            id: row.id,
            name: row.name,
            email: Shared::Domain::ValueObjects::Email.create(row.email),
            metadata: Domain::ValueObjects::CRMMetadata.rehydrate(row.metadata),
            created_at: row.created_at,
            updated_at: row.updated_at,
          )
        end

        def hydrate_row(customer, row)
          row.id = customer.id
          row.name = customer.name
          row.email = customer.email.value
          row.metadata = customer.metadata.to_h
          row.created_at = customer.created_at
          row.updated_at = customer.updated_at
          row
        end
      end
    end
  end
end
