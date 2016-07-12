require 'test_helper'

class CategoryTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "not signed in users don't have permission to see private categories" do
  	assert categories(:private).has_access?(nil) == false, "Not signed in user could access the private category!"
  end

  test "not signed in users should have permission to see private categories" do
  	assert categories(:public).has_access?(nil) == true, "Not signed in user couldn't access the public category!"
  end

  # test "friend user should have permission to see friends categories" do
  	# assert categories(:friend).has_access(users(:viktors_friend)) == true, "Friend doesn't have access to friends category!"
  # end
end
