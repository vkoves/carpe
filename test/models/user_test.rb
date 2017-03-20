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
    norm = users(:norm) # Grab our two users
    viktor  = users(:viktor)

    assert_not norm.following?(viktor), "Users should not be following each other by default." # By default, Norm should not be following Viktor

    norm.follow(viktor) # Have Norm follow Viktor
    viktor.confirm_follow(norm) # and Viktor confirm the follow

    assert norm.following?(viktor), "Following a user does not work, at least by \".following?\"" # after that, Norm should be following Viktor

    norm.unfollow(viktor) # Then have Norm unfollow Viktor
    assert_not norm.following?(viktor), "Unfollowing a user does not work, at least by \".following?\"" # and check it worked
  end

  test "should be able to make a user with name, email, and password" do
    test_user = User.new
    test_user.name = "test"
    test_user.email = "test@email.com"
    test_user.password = "password"
    assert_equal(test_user.save!, true, "Can save a user with only name")
  end
end
