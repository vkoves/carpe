# To run all tests, in the project directory run the command:
# bundle exec rake test
# ----------------------------------------
# To run this test, in the project directory run the command:
# bundle exec rake test test/controllers/event_test.rb

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "should follow and unfollow a user" do
    norm = users(:norm)
    viktor  = users(:viktor)
    assert_not norm.following?(viktor)
    norm.follow(viktor)
    assert norm.following?(viktor)
    norm.unfollow(viktor)
    assert_not norm.following?(viktor)
  end
end
