# rails-skeleton

A Ruby on Rails (API-only) skeleton that follows a **hexagonal / DDD architecture
with CQRS**, mirroring the NestJS bounded-context layout: `domain` → `application`
→ `infrastructure`, wired per context by a small container.

## Layout

```
app/
  controllers/
    health_controller.rb             # framework entrypoints (health, base)
    <context>/                       # HTTP adapter per context (Rails convention)
      <context>_controller.rb        # thin: params -> handler -> read model
  modules/
    shared/                          # shared kernel used by every context
      domain/
        aggregate_root.rb            # Shared::AggregateRoot
        domain_error.rb              # Shared::DomainError (+ one file per subclass)
        clock.rb                     # Shared::Clock (port) + Clock::System adapter
        value_objects/email.rb       # Shared::Email
    <context>/                       # one folder per bounded context
      domain/                        # aggregates, value objects, ports (pure Ruby)
        ports/                       # repository interfaces the domain depends on
      application/                   # use cases: commands, queries, read models
        commands/
        queries/
      infrastructure/                # non-HTTP adapters
        persistence/                 # ActiveRecord records, mappers, repositories
      container.rb                   # dependency wiring (the NestJS "module")
```

The HTTP controller is the one adapter kept in `app/controllers` instead of
inside the context folder: it is the framework's entrypoint, so Rails routing,
generators and test helpers expect it there. Everything else about the context
(domain, use cases, persistence) stays colocated under `app/modules/<context>`.

### Zeitwerk namespacing

Both `app/controllers` and `app/modules` are autoload roots, and the folder path
*is* the namespace. Zeitwerk **merges** the `<context>` namespace across roots, so
`app/controllers/customers/customers_controller.rb` and
`app/modules/customers/domain/customer.rb` both live under one `Customers::`.

The **layer folders** inside a context (`domain`, `application`,
`infrastructure` and their sub-folders) only organize files — they are
`collapse`d in `config/application.rb` so they add no namespace segment, matching
the NestJS layout where folders group but classes are flat. The result:

| File | Constant |
|------|----------|
| `customers/domain/customer.rb` | `Customers::Customer` |
| `customers/domain/value_objects/crm_metadata.rb` | `Customers::CRMMetadata` |
| `customers/domain/ports/customer_repository.rb` | `Customers::CustomerRepository` |
| `customers/application/commands/insert_customer_metadata.rb` | `Customers::InsertCustomerMetadata` (`::Command`, `::Handler`) |
| `customers/application/queries/get_customer_by_id.rb` | `Customers::GetCustomerById` |
| `customers/infrastructure/persistence/customer_record.rb` | `Customers::CustomerRecord` |
| `shared/domain/value_objects/email.rb` | `Shared::Email` |

### The dependency rule

- `domain` depends on nothing but the shared kernel — no Rails, no ActiveRecord.
- `application` orchestrates the domain and depends on **ports** (interfaces),
  never on concrete adapters.
- `infrastructure` and the context controller implement/consume the ports
  (ActiveRecord repository, HTTP controller) and are the only Rails-facing layers.

## CQRS

Each use case is one file under `application/commands` or `application/queries`,
holding a `Command`/`Query` value object plus a `Handler` with `#call`.
Controllers resolve handlers from the context's `Container` and translate the
returned **read model** to JSON. Domain errors bubble up and are mapped to HTTP
status codes by `ApplicationController`.

## Getting started

```bash
bundle install
bin/rails db:prepare
bin/rails server
curl localhost:3000/health   # => {"status":"ok"}
```

Requires Ruby 3.2.2 and a reachable PostgreSQL (see `config/database.yml`).
