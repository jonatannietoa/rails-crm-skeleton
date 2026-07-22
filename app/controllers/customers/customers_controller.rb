module Customers
  # HTTP adapter for the customers context. It lives in app/controllers (where
  # Rails routing, generators and test helpers expect controllers) while the rest
  # of the context — domain, application, persistence — stays under app/modules.
  # Zeitwerk merges the `Customers` namespace across both autoload roots.
  #
  # Controllers stay thin: build the command/query from params, hand it to the
  # handler resolved from the container, and render the returned read model.
  # Domain errors raised by the handlers are mapped to HTTP status codes by
  # ApplicationController.
  class CustomersController < ApplicationController
    # POST /customers
    def create
      attrs = create_params
      view = Customers::Container.insert_customer_metadata.call(
        Application::Commands::InsertCustomerMetadata::Command.new(
          name: attrs[:name],
          email: attrs[:email],
          metadata: metadata_attributes(attrs[:metadata]),
        ),
      )
      render json: view.to_h, status: :created
    end

    # GET /customers/:id
    def show
      view = Customers::Container.get_customer_by_id.call(
        Application::Queries::GetCustomerById::Query.new(id: params[:id]),
      )
      render json: view.to_h
    end

    private

    def create_params
      params.permit(
        :name,
        :email,
        metadata: [:source, :external_id, :entity_type, :list_entry_id, { fields: {}, tags: [] }],
      )
    end

    def metadata_attributes(raw)
      raw ||= ActionController::Parameters.new
      {
        source: raw[:source],
        external_id: raw[:external_id],
        entity_type: raw[:entity_type],
        list_entry_id: raw[:list_entry_id],
        fields: raw[:fields]&.to_h || {},
        tags: raw[:tags] || [],
      }
    end
  end
end
