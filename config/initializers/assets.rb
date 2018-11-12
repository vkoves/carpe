# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('node_modules')
Rails.application.config.assets.paths << Rails.root.join('test', 'fixtures', 'files')

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( admin.js admin.css )

Rails.application.config.assets.precompile += %w(carpe.css)
Rails.application.config.assets.precompile += %w(schedule.css)
Rails.application.config.assets.precompile += %w(profile.css)
Rails.application.config.assets.precompile += %w(login.css)
Rails.application.config.assets.precompile += %w(jquery-ui.min.css)
Rails.application.config.assets.precompile += %w(header.css)
Rails.application.config.assets.precompile += %w(activity.css)
Rails.application.config.assets.precompile += %w(schedule.js)
Rails.application.config.assets.precompile += ["groups/index.js", "groups/show.js"]
Rails.application.config.assets.precompile += %w(admin-panel.js)
Rails.application.config.assets.precompile += %w(utilities.js)
Rails.application.config.assets.precompile += %w(token-input-facebook.css)
Rails.application.config.assets.precompile += %w(token-input.css)
Rails.application.config.assets.precompile += %w(pages.css)
Rails.application.config.assets.precompile += %w(home.css)
Rails.application.config.assets.precompile += %w(groups.css)

# Pages
Rails.application.config.assets.precompile += %w(pages/admin.css)

# Testing Files
Rails.application.config.assets.precompile += %w(sample_avatar.jpg)
