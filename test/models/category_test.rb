require 'test_helper'

class CategoryTest < ActiveSupport::TestCase
  def setup
    @norm, @putin = users(:norm, :putin)
  end

  test "not signed in users don't have permission to see private categories" do
    assert_not categories(:private).accessible_by?(nil),
               "Not signed in user could access the private category!"
  end

  test "not signed in users should have permission to see public categories" do
    assert categories(:public).accessible_by?(nil),
           "Not signed in user couldn't access the public category!"
  end

  test "categories can be destroyed" do
    categories(:main).destroy
    assert_empty categories(:main).events, "All related events should have been destroyed"
    assert_not categories(:main).persisted?, "Category should be marked as destroyed/deleted"
  end

  test "users have access to categories in their group" do
    private_category = categories(:private)
    private_category.group = groups(:one)
    private_category.save!

    assert private_category.accessible_by?(@norm),
           "Member of group does not have access to their group category!"
  end

  test "followers should be able to view categories with 'followers' privacy" do
    putins_category = categories(:followers)
    putins_category.user = @putin
    @norm.follow(@putin)

    assert putins_category.accessible_by?(@norm),
           "Follower does not have access to category with 'followers' privacy"
  end
end
