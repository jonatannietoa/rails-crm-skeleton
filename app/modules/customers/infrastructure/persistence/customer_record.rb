module Customers
  # ActiveRecord row for the customers table. This is a persistence detail: it
  # never leaves the infrastructure layer — the mapper converts it to and from
  # the Customer aggregate.
  class CustomerRecord < ActiveRecord::Base
    self.table_name = "customers"
  end
end
