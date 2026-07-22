module Customers
  # Dependency wiring for the customers context — the Ruby counterpart of the
  # NestJS module's `providers`. It binds the CustomerRepository port to its
  # ActiveRecord adapter and builds handlers with their collaborators injected,
  # so controllers depend on the container, never on concrete classes.
  class Container
    class << self
      def customer_repository
        @customer_repository ||= Infrastructure::Persistence::ActiveRecordCustomerRepository.new
      end

      def clock
        @clock ||= Shared::Domain::Clock::System.new
      end

      def insert_customer_metadata
        Application::Commands::InsertCustomerMetadata::Handler.new(
          customers: customer_repository,
          clock: clock,
        )
      end

      def get_customer_by_id
        Application::Queries::GetCustomerById::Handler.new(customers: customer_repository)
      end

      # Test seam: swap adapters (e.g. an in-memory repository) and reset state.
      attr_writer :customer_repository, :clock

      def reset!
        @customer_repository = nil
        @clock = nil
      end
    end
  end
end
