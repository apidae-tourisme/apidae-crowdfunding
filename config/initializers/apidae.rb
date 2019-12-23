MEMBERS_API_URL = ''

# Apidae SSO config
Rails.application.config.oauth_config = {
    auth_site: '',
    token_path: ''
}
Rails.application.config.omniauth_config = {
    authorize_site: '',
    auth_site: '',
    client_id: '',
    client_secret: '',
    profile_url: ''
}

require_relative 'omniauth_strategy'