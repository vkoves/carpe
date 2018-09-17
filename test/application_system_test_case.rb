require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  Capybara.register_driver :custom_chrome do |app|
    capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
      chromeOptions: {
        args: %w[headless disable-gpu
                 window-size=1920,1080
                 remote-debugging-port=9222
                 no-sandbox disable-dev-shm-usage]
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
