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
