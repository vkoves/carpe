require "test_helper"
require "utilities"

class UtilitiesTest < ActiveSupport::TestCase
  include Utilities

  def setup
    # NOTE: Time.now and friends are all based on this date.
    # This will help keep tests predictable.
    new_current_time = Time.parse("15th May 2018 5:00:00 PM") # a tuesday
    travel_to new_current_time
  end

  # ----------------------------------
  # #relative_time - Past Times
  # ----------------------------------

  test "#relative_time works (> 1 month ago)" do
    test_time = Time.parse("5th April 2018 5:30:00 PM")
    str = test_time.strftime(relative_time(test_time))

    assert_equal "1 month ago", str
  end

  test "#relative_time works (> 1 week ago)" do
    test_time = Time.parse("6th May 2018 3:00:00 PM")
    str = test_time.strftime(relative_time(test_time))

    assert_equal "9 days ago", str
  end

  test "#relative_time works (> 1 day ago)" do
    test_time = Time.parse("10th May 2018 3:00:00 PM")
    str = test_time.strftime(relative_time(test_time))

    assert_equal "last Thursday at 3:00 PM", str
  end

  test "#relative_time works (yesterday)" do
    test_time = Time.parse("14th May 2018 3:00:00 PM")
    str = test_time.strftime(relative_time(test_time))

    assert_equal "yesterday at 3:00 PM", str
  end

  test "#relative_time works (>= 1 hour ago)" do
    test_time = Time.parse("15th May 2018 2:30:00 PM")
    str = test_time.strftime(relative_time(test_time))

    assert_equal "2:30 PM", str
  end

  test "#relative_time works (< 1 hour ago)" do
    test_time = Time.parse("15th May 2018 4:45:00 PM")
    str = test_time.strftime(relative_time(test_time))

    assert_equal "15 minutes ago (4:45 PM)", str
  end

  test "#relative_time works (< 1 minute ago)" do
    test_time = Time.parse("15th May 2018 4:59:30 PM")
    str = test_time.strftime(relative_time(test_time))

    assert_equal "30 seconds ago (4:59 PM)", str
  end

  # ----------------------------------
  # #relative_time - Future Times
  # ----------------------------------

  test "#relative_time works (< 1 minute from now)" do
    test_time = Time.parse("15th May 2018 5:00:30 PM")
    str = test_time.strftime(relative_time(test_time))

    assert_equal "30 seconds from now (5:00 PM)", str
  end

  test "#relative_time works (< 1 hour from now)" do
    test_time = Time.parse("15th May 2018 5:30:00 PM")
    str = test_time.strftime(relative_time(test_time))

    assert_equal "30 minutes from now (5:30 PM)", str
  end

  test "#relative_time works (>= 1 hour from now)" do
    test_time = Time.parse("15th May 2018 11:30:00 PM")
    str = test_time.strftime(relative_time(test_time))

    assert_equal "11:30 PM", str
  end

  test "#relative_time works (tomorrow)" do
    test_time = Time.parse("16th May 2018 1:00:00 PM")
    str = test_time.strftime(relative_time(test_time))

    assert_equal "tomorrow at 1:00 PM", str
  end

  test "#relative_time works (> 1 day from now)" do
    test_time = Time.parse("17th May 2018 7:00:00 PM")
    str = test_time.strftime(relative_time(test_time))

    assert_equal "Thursday at 7:00 PM", str
  end

  test "#relative_time works (> 1 week from now)" do
    test_time = Time.parse("23rd May 2018 3:00:00 PM")
    str = test_time.strftime(relative_time(test_time))

    assert_equal "8 days from now", str
  end

  test "#relative_time works (> 1 month from now)" do
    test_time = Time.parse("20th June 2018 5:30:00 PM")
    str = test_time.strftime(relative_time(test_time))

    assert_equal "1 month from now", str
  end

  test "#relative_time works with time zones" do
    travel_to Time.parse("3rd October 2018 9:50:00 PM") # a wednesday

    Time.use_zone("America/Chicago") do
      test_time = Time.parse("5th October 2018 8:00:00 AM") # a friday
      str = test_time.strftime(relative_time(test_time))
      assert_equal "Friday at 8:00 AM", str
    end
  end

  # ----------------------------------
  # other tests
  # ----------------------------------

  test "#range works" do
    assert_equal [], range(0, 0, 1).to_a
    assert_equal [2], range(2, 3, 1).to_a
    assert_equal [0, 1, 2], range(0, 3, 1).to_a
    assert_equal [2, 4, 6], range(2, 8, 2).to_a
  end
end
