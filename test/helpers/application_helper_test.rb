require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  test "#relative_event_time_tag works with current events" do
    event = events(:current_event_1)
    event.date = Time.current - 1.hour
    event.end_date = Time.current + 1.hour

    html_output = relative_event_time_tag(event)
    assert_match(/Started/, html_output)
    assert_match(/ends/, html_output)
  end

  test "#validation_error_messages! works" do
    new_user = User.new # this monster doesn't even have a name.
    new_user.save

    html_output = validation_error_messages! new_user
    assert_match(/Name/, html_output)
    assert_match(/blank/, html_output)
  end
end
