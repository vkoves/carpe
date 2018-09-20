require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase

  # Chrome Options Explained
  #
  # headless:
  # Runs Chrome without launching a window. You can disable this if you want
  # to watch the tests perform their actions.
  #
  # no-sandbox:
  # When running in a headless Chrome in a Docker container without a user,
  # this option is required.
  #
  # disable-dev-shm-usage:
  # Prevents Headless Chrome from blowing Docker memory limits on Travis
  #
  Capybara.register_driver :custom_chrome do |app|
    capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
      chromeOptions: {
        args: %w[window-size=1920,1080 no-sandbox disable-dev-shm-usage]
      }
    )

    Capybara::Selenium::Driver.new(
      app, browser: :chrome, desired_capabilities: capabilities
    )
  end

  # To disable headless mode, remove `headless` from the capabilities list.
  # To re-enable animations, comment out the NoAnimations line in test.rb.
  driven_by :custom_chrome
end
