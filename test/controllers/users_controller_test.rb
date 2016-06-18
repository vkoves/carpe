# To run this test, in the project directory run the command:
# bundle exec rake test test/controllers/users_controller_test.rb

require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  test "should route to user" do #test if the users route is working properly
    assert_routing '/u/1', { controller: "users", action: "show", id: "1" }
  end
end
