require 'test_helper'

class GroupTest < ActiveSupport::TestCase
  def setup
    @viktor, @norm = users(:viktor, :norm)
    @group1, @group2 = groups(:one, :two)
  end
  
  test "#avatar_url uses correct avatar" do
    assert_match /gravatar/, @group1.avatar_url,
                 "Expected group without avatar to use gravatar as a default avatar"

    @group2.avatar = sample_file("sample_avatar.jpg")
    @group2.save!

    assert_match /sample_avatar/, @group2.avatar_url,
                 "Expected url to be the path to the group's uploaded avatar"
  end

  test "#role returns the correct group member roles" do
    assert_equal :admin, @group1.role(@viktor)
    assert_equal :member, @group1.role(@norm)
    assert_equal :owner, groups(:four).role(users(:joe))
    assert_nil @group2.role(@viktor)
  end

  test "#in_group? correctly returns whether user is a group member" do
    assert @viktor.in_group?(@group1)
    assert_not users(:viktors_friend).in_group?(@group1)
  end

  test "only owner can promote users in group" do
    ability = Ability.new(users(:joe))
    assert ability.can? :update, groups(:four)
  end
end
