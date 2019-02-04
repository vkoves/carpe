require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RubyGettingStarted
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    config.paperclip_avatar_settings = [
      styles: {
        thumb: "60x60#",
        profile: "150x150#"
      },
      convert_options: {
        thumb: "-quality 75 -strip -layers optimize",
        profile: "-quality 75 -strip -layers optimize"
      }
    ]

    config.paperclip_avatar_validations = {
      content_type: { content_type: /\Aimage/ },
      size: { in: 0..3.megabytes }
    }

    config.paperclip_banner_settings = [
      styles: {
        desktop: { geometry: "1500x200#", animated: false },
        mobile: { geometry: "500x200#", animated: false }
      },
      convert_options: {
        desktop: "-quality 75 -strip",
        mobile: "-quality 50 -strip"
      }
    ]

    config.paperclip_banner_validations = {
      content_type: { content_type: /\Aimage/ },
      size: { in: 0..5.megabytes }
    }
  end
end
