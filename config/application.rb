require_relative "boot"

require "rails"
# Only the frameworks this API needs — no view/asset/mailer stack.
require "active_model/railtie"
require "active_record/railtie"
require "action_controller/railtie"

# Require the gems listed in Gemfile, including any gems
# limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RailsSkeleton
  class Application < Rails::Application
    config.load_defaults 7.1

    # API-only: skip cookies, sessions, flash and the middleware that serves views.
    config.api_only = true

    config.time_zone = "UTC"

    # Bounded contexts live under app/modules/<context>. Direct children of app/
    # are Zeitwerk autoload roots, so app/modules is a root and each first-level
    # folder is a top namespace (Shared::, Customers::, ...).
    #
    # The layer folders inside a context (domain, application, infrastructure and
    # their sub-folders) only ORGANIZE files — they do not add a namespace
    # segment. This mirrors the NestJS layout, where folders group files but the
    # classes are flat. We collapse them so, e.g.:
    #   app/modules/customers/application/commands/insert_customer_metadata.rb
    #     -> Customers::InsertCustomerMetadata
    #   app/modules/shared/domain/value_objects/email.rb
    #     -> Shared::Email
    Rails.autoloaders.main.collapse(
      Rails.root.join("app/modules/*/domain").to_s,
      Rails.root.join("app/modules/*/domain/*").to_s,
      Rails.root.join("app/modules/*/application").to_s,
      Rails.root.join("app/modules/*/application/*").to_s,
      Rails.root.join("app/modules/*/infrastructure").to_s,
      Rails.root.join("app/modules/*/infrastructure/*").to_s,
    )
  end
end
