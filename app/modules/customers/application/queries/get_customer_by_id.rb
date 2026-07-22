module Customers
  module Application
    module Queries
      # Use case: fetch a single customer (with its CRM metadata) by id.
      module GetCustomerById
        Query = Data.define(:id)

        class Handler
          def initialize(customers:)
            @customers = customers
          end

          # @return [Customers::Application::CustomerReadModel]
          def call(query)
            customer = @customers.find_by_id(query.id)
            unless customer
              raise Shared::Domain::NotFoundError,
                "No customer exists with id \"#{query.id}\"."
            end

            CustomerReadModel.from(customer)
          end
        end
      end
    end
  end
end
