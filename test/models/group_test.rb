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

  test "#get_role returns the correct group member roles" do
    assert_equal "admin", @group1.get_role(@viktor)
    assert_equal "member", @group1.get_role(@norm)
    assert_equal "none", @group2.get_role(@viktor)
  end

  test "#in_group? correctly returns whether user is a group member" do
    assert @group1.in_group?(@viktor)
    assert_not @group1.in_group?(users(:viktors_friend))
  end
end
