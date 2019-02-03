require "test_helper"

class EventInviteTest < ActiveSupport::TestCase
  def setup
    @viktor, @putin = users(:viktor, :putin)
  end

  test "#accept! creates a hosted event" do
    assert_difference -> { @putin.events.count }, +1 do
      event_invites(:putin_music).accept! # invitation from viktor to putin
    end
  end

  test "#accept! creates a category when necessary" do
    assert_difference -> { @putin.categories.count }, +1 do
      event_invites(:putin_music).accept!
    end

    assert_equal "Event Invites", @putin.categories.last.name
    assert_equal @putin, @putin.categories.last.owner
  end

  test "#hosted_event?" do
    event_invites(:putin_music).accept!

    assert @putin.events.last.hosted_event?
    assert_equal @putin.events.last, event_invites(:putin_music).hosted_event
    assert_not event_invites(:putin_music).host_event.hosted_event?
    assert_not events(:event_to_delete).hosted_event?
  end

  test "#host_event?" do
    event_invites(:putin_music).accept!

    assert event_invites(:putin_music).host_event.host_event?
    assert_not @putin.events.last.host_event?
    assert_not events(:event_to_delete).host_event?
  end

  test "deleting event invite removes associated hosted event" do
    invite = event_invites(:joe_music)

    assert_difference -> { Event.count }, -1 do
      invite.destroy!
    end
  end
end
