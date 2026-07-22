module Customers
  module Domain
    module Ports
      # Persistence port for the Customer aggregate. The application layer depends
      # on this interface; infrastructure provides the concrete adapter. Include
      # this module in adapters to document intent and inherit the contract.
      module CustomerRepository
        def save(_customer)
          raise NotImplementedError, "#{self.class} must implement #save"
        end

        def find_by_id(_id)
          raise NotImplementedError, "#{self.class} must implement #find_by_id"
        end

        def find_by_email(_email)
          raise NotImplementedError, "#{self.class} must implement #find_by_email"
        end
      end
    end
  end
end
