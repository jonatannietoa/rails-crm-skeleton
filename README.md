# rails-skeleton

A Ruby on Rails (API-only) skeleton that follows a **hexagonal / DDD architecture
with CQRS**, mirroring the NestJS bounded-context layout: `domain` → `application`
→ `infrastructure`, wired per context by a small container.

## Layout

```
app/
  controllers/                       # framework entrypoints (health, base)
  modules/
    shared/                          # shared kernel used by every context
      domain/
        aggregate_root.rb            # identity + equality for aggregates
        domain_error.rb              # InvalidInput / BusinessRule / NotFound
        clock.rb                     # time source port + System adapter
        value_objects/email.rb
    <context>/                       # one folder per bounded context
      domain/                        # aggregates, value objects, ports (pure Ruby)
        ports/                       # repository interfaces the domain depends on
      application/                   # use cases: commands, queries, read models
        commands/
        queries/
      infrastructure/                # adapters: http controllers, persistence
        http/
        persistence/                 # ActiveRecord records, mappers, repositories
      container.rb                   # dependency wiring (the NestJS "module")
```

### Zeitwerk namespacing

`app/modules` is an autoload root, so the folder path *is* the namespace:
`app/modules/customers/domain/customer.rb` defines `Customers::Domain::Customer`.

### The dependency rule

- `domain` depends on nothing but the shared kernel — no Rails, no ActiveRecord.
- `application` orchestrates the domain and depends on **ports** (interfaces),
  never on concrete adapters.
- `infrastructure` implements the ports (ActiveRecord repository, HTTP controller)
  and is the only layer that touches Rails.

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
