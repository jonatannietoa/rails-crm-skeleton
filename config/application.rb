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

    # Bounded contexts live under app/modules/<context> and are namespaced by
    # folder (Zeitwerk): app/modules/customers/domain/customer.rb defines
    # Customers::Domain::Customer. Direct children of app/ are autoload roots,
    # so app/modules is a root and each first-level folder is a top namespace
    # (Shared::, Customers::, ...). No extra autoload config is required.
  end
end
