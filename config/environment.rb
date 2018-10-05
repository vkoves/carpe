# Load the Rails application.
require_relative 'application'

ActionMailer::Base.smtp_settings = {
  :user_name => 'indigobox',
  :password => 'swimmingMail13',
  :domain => 'carpe.us',
  :address => 'smtp.sendgrid.net',
  :port => 587,
  :authentication => :plain,
  :enable_starttls_auto => true
}

# Initialize the Rails application.
Rails.application.initialize!

# Use the action mailer defaults which are defined per-environment
Rails.application.default_url_options = Rails.application.config.action_mailer.default_url_options
