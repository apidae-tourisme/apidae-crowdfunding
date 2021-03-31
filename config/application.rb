require 'uri'
require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ApidaeCrowdfunding
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    config.i18n.default_locale = :fr
    config.time_zone = 'Paris'

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.cache_store = :file_store, 'cache', {expires_in: 2.hours}

    # Mailer config
    config.action_mailer.smtp_settings = {
        address: '',
        port: 587,
        domain: '',
        user_name: '',
        password: '',
        authentication: 'plain',
        enable_starttls_auto: true
    }

    # Send inline emails as default
    config.active_job.queue_adapter = :inline

    # Active storage mode
    config.active_storage.service = :local

    # Change default order to prevent catch-all routes from catching AS routes (see https://github.com/rails/rails/issues/31228#issuecomment-479631062)
    config.railties_order = [:all, :main_app]

    config.sender_email = ''
    config.subscriptions_admins = []
  end
end
