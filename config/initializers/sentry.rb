if Rails.env.production?
  Raven.configure do |config|
    config.dsn = ''
  end
end