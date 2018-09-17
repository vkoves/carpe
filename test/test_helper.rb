# Add SimpleCov
require 'simplecov'
SimpleCov.start do
  add_filter "/test/"
  coverage_dir "public/coverage"
end

# Add Minitest reporting
require "minitest/reporters"
Minitest::Reporters.use! [Minitest::Reporters::HtmlReporter.new(:reports_dir => "public/html_reports"), Minitest::Reporters::DefaultReporter.new]

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def sample_file(filename)
    File.new("#{Rails.root}/test/fixtures/files/#{filename}")
  end
end

# Capybara documentation:
# https://github.com/teamcapybara/capybara
#
# Capybara cheat sheet:
# https://gist.github.com/zhengjia/428105
#
# Capybara mini-test assertions documentation:
# https://www.rubydoc.info/gems/capybara/Capybara/Minitest/Assertions
class ActionDispatch::SystemTestCase
  def sign_in(email, password)
    visit new_user_session_path

    within 'form' do
      fill_in 'Email', with: email
      fill_in 'Password', with: password
      click_on 'Sign In'
    end
  end

  # Clicks an element with the given text (as opposed to a css selector)
  # in the current scope
  def click_text(text)
    find(:xpath, ".//*[contains(text(), '#{text}')]").click
  end

  # Similar to fill_in, but works with contenteditable and triggers javascript
  def type(text, into:)
    find(into).send_keys(text)
  end

  # Overrides the default capybara `click` that only works for buttons and anchors.
  # This one works with any tag and also accepts nodes.
  def click(selector)
    if selector.is_a? String
      find(selector).click
    else
      selector.click
    end
  end
end
