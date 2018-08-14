require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RubyGettingStarted
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rails -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = "UTC"
    config.active_record.default_timezone = :utc

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    config.paperclip_avatar_settings = [
      styles: {
        thumb: '60x60#',
        profile: '150x150#'
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
        desktop: { geometry: '1500x200#', animated: false },
        mobile: { geometry: '500x200#', animated: false }
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
