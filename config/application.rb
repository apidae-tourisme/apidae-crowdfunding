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

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

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

    config.sender_email = ''
    config.subscriptions_admins = []

  end
end
