require "active_support/core_ext/integer/time"
Rails.application.configure do
  config.enable_reloading = true
  config.eager_load = false
  config.consider_all_requests_local = true
  config.active_storage.service = :local
  config.action_mailer.delivery_method = :file
  config.action_mailer.file_settings = { location: Rails.root.join("tmp", "mail") }
  config.action_mailer.default_url_options = { host: "localhost", port: 3000 }
  config.active_job.queue_adapter = :async
  config.hosts.clear
end
