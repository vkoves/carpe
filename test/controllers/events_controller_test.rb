class EventsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "signed in users can delete their event" do
    sign_in users(:norm)
    assert_difference -> { Event.count }, -1 do
      delete event_url(events(:event_to_delte))
    end
  end
end