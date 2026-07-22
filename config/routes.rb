Rails.application.routes.draw do
  get "/health", to: "health#show"

  # Bounded-context controllers live in app/controllers/<context> (Rails
  # convention). The rest of each context (domain/application/persistence)
  # lives under app/modules/<context>; Zeitwerk merges the namespace.

  # Customers context
  post "/customers", to: "customers/customers#create"
  get  "/customers/:id", to: "customers/customers#show"
end
