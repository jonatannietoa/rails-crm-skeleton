Rails.application.routes.draw do
  get "/health", to: "health#show"

  # Bounded-context routes are mounted per module. Controllers live under
  # app/modules/<context>/infrastructure/http and are referenced by their
  # full path (Rails maps "a/b/c#action" -> A::B::CController).

  # Customers context
  post "/customers", to: "customers/infrastructure/http/customers#create"
  get  "/customers/:id", to: "customers/infrastructure/http/customers#show"
end
