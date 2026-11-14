require "active_support/core_ext/integer/time"
Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = true
  config.consider_all_requests_local = false
  config.force_ssl = true
  config.assume_ssl = true
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")
  config.log_tags = [ :request_id ]
  config.active_storage.service = :local # replace with persistent private object storage before production
  config.action_mailer.default_url_options = { host: ENV.fetch("APP_HOST") }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address: ENV.fetch("SMTP_HOST"), port: ENV.fetch("SMTP_PORT", 587).to_i,
    user_name: ENV.fetch("SMTP_USERNAME"), password: ENV.fetch("SMTP_PASSWORD"),
    authentication: :plain, enable_starttls_auto: true
  }
  config.active_job.queue_adapter = :async # switch to Solid Queue for production before launch
end
