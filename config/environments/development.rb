Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # log level 
  config.log_level = :debug
  config.log_level = :info
  config.logger = Logger.new(STDOUT)

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = true

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true
  #
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      address: "localhost",
      port: "1025",
    }
  
#  if ENV['SEND_MAIL_PROVIDER'].eql?('mailgun')
#    config.action_mailer.delivery_method = :mailgun
#    config.action_mailer.mailgun_settings = {
#      api_key: "key-37741c2a664f0f0e6a5d78e341975444",
#      domain: "mg.zhouhuan.top",
#    }
#  else
#    config.action_mailer.delivery_method = :smtp
#    config.action_mailer.smtp_settings = {
#      address: "localhost",
#      port: "1025",
#    }
#  end
end
