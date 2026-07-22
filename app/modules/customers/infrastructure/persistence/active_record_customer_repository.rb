module Customers
  module Infrastructure
    module Persistence
      # CustomerRepository port implemented over ActiveRecord/PostgreSQL.
      class ActiveRecordCustomerRepository
        include Domain::Ports::CustomerRepository

        def save(customer)
          row = CustomerRecord.find_or_initialize_by(id: customer.id)
          CustomerMapper.hydrate_row(customer, row)
          row.save!
          nil
        end

        def find_by_id(id)
          row = CustomerRecord.find_by(id: id)
          row && CustomerMapper.to_domain(row)
        end

        def find_by_email(email)
          row = CustomerRecord.find_by(email: email)
          row && CustomerMapper.to_domain(row)
        end
      end
    end
  end
end
