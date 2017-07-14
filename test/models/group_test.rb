require 'test_helper'

class GroupTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "group image helper falls back to gravatar" do
    assert_equal(groups(:two).avatar_url, groups(:two).image_url, "Group with image url uses that image")
    assert_match(/gravatar/, groups(:one).avatar_url, "Lazy group with no avatar uses a gravatar backup")
  end

  test "group should fetch user role" do
    assert_equal(groups(:one).get_role(users(:viktor)), "admin", "Admin user should have role returned admin")
    assert_equal(groups(:one).get_role(users(:norm)), "member", "Other user should have role returned as stored")
  end

  test "group role should recognize non members" do
    assert_equal(groups(:two).get_role(users(:viktor)), "none", "Non members should have role returned as none")
  end

  test "in group should return membership" do
    assert_equal(groups(:one).in_group?(users(:viktor)), true, "Member in group should have in_group? return true")
    assert_equal(groups(:one).in_group?(users(:viktors_friend)), false, "Member not in group should have in_group? return false")
  end
end
