require_relative "boot"
require "rails/all"
Bundler.require(*Rails.groups)
module Answerloop
  class Application < Rails::Application
    config.load_defaults 8.1
    config.autoload_lib(ignore: %w[assets tasks])
    config.time_zone = "UTC"
    config.active_record.default_timezone = :utc
    config.generators do |g|
      g.test_framework :rspec, fixtures: false
    end
  end
end
