source "https://rubygems.org"

ruby "2.4.2"
gem "rails", "~> 5.2"

# Required gems for rails
gem "coffee-rails", "~> 4.2"
gem "jbuilder", "~> 2.7"
gem "puma", "~> 3.10"
gem "sass-rails", ">= 5.0.5"
gem "uglifier", ">= 1.3.0"
# gem "turbolinks", "~> 5"
gem "bootsnap", "~> 1.3"
gem "tzinfo-data", platforms: [:mswin, :mingw, :x64_mingw]

#####################################
####### Actual Carpe Gems ###########
#####################################

# bundle exec rails doc:rails generates the API under doc/api.
gem "sdoc", group: :doc

# Databases
gem "mysql2", group: :production
gem "sqlite3", group: [:development, :test]

# Use devise for authentication
gem "devise", "~> 4.3"

# Use omniauth to allow different logins
gem "omniauth", "~> 1.7"
gem "omniauth-google-oauth2"

# Use rubycritic to detect code smell and problems (https://github.com/whitesmith/rubycritic)
gem "rubycritic", require: false, group: :development

# Use chartkick to make graphs using the Google Graph API
gem "chartkick", "~> 2.2"

# Premiler, used for styling emails nicely by inlining styles
gem "premailer-rails"

# Use rack-mini-profiler for investigating site speed (https://github.com/MiniProfiler/rack-mini-profiler)
gem "rack-mini-profiler", group: [:development, :production]

# Paperclip gem for managing user uploaded images and such (https://github.com/thoughtbot/paperclip)
gem "paperclip", "~> 6"

# Amazon Web Storage Service. Used by paperclip to store images.
gem "aws-sdk-s3", "~> 1", require: false, group: :production

# Add SimpleCov to check test coverage (https://github.com/colszowka/simplecov)
gem "simplecov", require: false, group: :test

# Add teaspoon gem for JS testing (https://github.com/jejacks0n/teaspoon) with Mocha
gem "teaspoon", "~> 1.1"
gem "teaspoon-mocha"

# Minitest reporting
gem "minitest-reporters"

# Kaminari helps lazy load large database lists (https://github.com/kaminari/kaminari)
gem "kaminari", "~> 1.1.1"

# LSG
gem "livingstyleguide"

# A more informative exception template page
gem "better_errors", group: :development

# A repl that can be used on the exception template page
gem "binding_of_caller", group: :development

# Use jQuery as the JavaScript library
gem "jquery-rails", "~> 4.3"

# Add jQuery UI gem
gem "jquery-ui-rails", "~> 6.0"

# Used for permission authorization
gem "cancancan", "~> 2.2.0"

# Non-stupid non-digest assets for non digest LSG files
gem "non-stupid-digest-assets"

# Used for acceptance tests
gem "capybara", "~> 3"

# Used for acceptance tests & teaspoon tests
gem "selenium-webdriver", "~> 3"
gem "webdrivers", "~> 3"

# Linters:
# Not required since they are only for CI/development
gem "erb_lint", require: false
gem "rubocop", "~> 0.60.0", require: false
gem "scss_lint", require: false

# Webpacker for packing Vue
gem "webpacker", "~> 3.5"
