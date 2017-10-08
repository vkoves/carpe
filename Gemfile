source 'https://rubygems.org'
ruby '2.3.0'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.0'

group :production do
	# MySQL
	gem 'mysql2', '~> 0.3.18'
end

gem 'rails_12factor', group: :production

# Use SCSS for stylesheets
gem 'sass-rails'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use jQuery as the JavaScript library
gem 'jquery-rails'

# Add jQuery UI gem
gem 'jquery-ui-rails'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.

gem 'sdoc', '~> 0.4.0',          group: :doc

# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
# gem 'spring',        group: :development

gem 'puma'

# explicitly include the cofee-script gem to prevent implicit require that result in the following message:
# "WARN: tilt autoloading 'coffee_script' in a non thread-safe way; explicit require 'coffee_script' suggested."
gem 'coffee-rails'

group :development, :test do
  # Windows developers, refer to: https://github.com/sparklemotion/sqlite3-ruby/issues/185 to deal with
  # `require': cannot load such file -- sqlite3/sqlite3_native (LoadError)
  # Essentially, you just need to build sqlite3 >= 1.3.11 and uninstall the bundled mingw sqlite.
  gem 'sqlite3'
end

#####################################
####### Actual Carpe Gems ###########
#####################################

# Use devise for authentication
gem 'devise'

# Use omniauth to allow different logins
gem 'omniauth'

# Google omniauth
gem 'omniauth-google-oauth2'

# Use local-time for timezone handling, most likely unused ATM
gem 'local_time'

# Use rubycritic to detect code smell and problems (https://github.com/whitesmith/rubycritic)
gem 'rubycritic', :require => false, group: :development

# Use chartkick to make graphs using the Google Graph API
gem 'chartkick'

# Roadie, used for styling emails nicely
gem 'roadie', '~> 3.1.1'

# Use rack-mini-profiler for investigating site speed (https://github.com/MiniProfiler/rack-mini-profiler)
gem 'rack-mini-profiler', group: [:development, :production]

# Paperclip gem for managing user uploaded images and such (https://github.com/thoughtbot/paperclip)
gem 'paperclip'

# AWS SDK gem for connecting to Amazon S3 and other tools (https://github.com/aws/aws-sdk-ruby)
gem 'aws-sdk', '~> 2', group: :production

if Gem.win_platform?
  # Used by Windows for time zone differences (strange indeed).
  gem 'tzinfo-data'

  gem 'coffee-script-source', '>= 1.12.2'
end

# Add SimpleCov to check test coverage (https://github.com/colszowka/simplecov)
gem 'simplecov', :require => false, :group => :test

# Add teaspoon gem for JS testing (https://github.com/jejacks0n/teaspoon) with Mocha
gem "teaspoon"
gem "teaspoon-mocha"

# Minitest reporting
gem "minitest-reporters"

# LSG
gem "livingstyleguide"