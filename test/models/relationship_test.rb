require 'test_helper'

class RelationshipTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "other user returns not the user passed in" do
    rel1 = relationships(:one)
    assert_equal(rel1.other_user(rel1.follower), rel1.followed)
    assert_equal(rel1.other_user(rel1.followed), rel1.follower)
  end

  test "denying a follow request should work" do
    rel1 = relationships(:one)
    assert_not rel1.confirmed?, "Relationship 1 starts unconfirmed"
    rel1.deny
    assert_not rel1.confirmed?, "Relationship 1 ends denied"
  end

  test "confirming a follow request should work" do
    rel1 = relationships(:one)
    assert_not rel1.confirmed?, "Relationship 1 starts unconfirmed"
    rel1.confirm
    assert rel1.confirmed?, "Relationship 1 ends confirmed"
  end
end
