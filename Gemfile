source 'https://rubygems.org'
ruby '2.3.0'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.0'

group :production do
	#MYSQL
	gem 'mysql2'
end

# Use postgresql as the database for Active Record
# gem 'pg'
gem 'rails_12factor', group: :production
# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.3'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .js.coffee assets and views
# gem 'coffee-rails', '~> 4.0.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer',  platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-ui-rails' #Add jQuery UI gem
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0',          group: :doc

# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
# gem 'spring',        group: :development

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

gem 'puma'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]

group :development, :test do
  # Windows developers, refer to: https://github.com/sparklemotion/sqlite3-ruby/issues/185 to deal with
  # `require': cannot load such file -- sqlite3/sqlite3_native (LoadError)
  # Essentially, you just need to build sqlite3 >= 1.3.11 and uninstall the bundled mingw sqlite.
  gem 'sqlite3'
end

#####################################
####### Actual Carpe Gems ###########
#####################################

#Use devise for authentication
gem 'devise'

#Use omniauth to allow different logins
gem 'omniauth'

#Google omniauth
gem 'omniauth-google-oauth2'

#Use local-time for timezone handling, most likely unused ATM
gem 'local_time'

#Use rubycritic to detect code smell and problems (https://github.com/whitesmith/rubycritic)
gem 'rubycritic', :require => false

#Use chartkick to make graphs using the Google Graph API
gem 'chartkick'

#Roadie, used for styling emails nicely
gem 'roadie', '~> 3.1.1'

if Gem.win_platform?
  # Used by Windows for time zone differences (strange indeed).
  gem 'tzinfo-data'
end
