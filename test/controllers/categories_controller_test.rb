require 'test_helper'

class CategoriesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "group owner can add categories" do
    sign_in users(:ownerAlice)

    assert_difference -> { Category.count }, +1 do
      post categories_path, params: { group_id: groups(:publicGroup).id,
                                      name: "cool category" }
    end
  end

  test "group moderator can add categories" do
    sign_in users(:moderatorMaven)

    assert_difference -> { Category.count }, +1 do
      post categories_path, params: { group_id: groups(:publicGroup).id,
                                      name: "cool category" }
    end
  end

  test "group memeber cannot add categories" do
    sign_in users(:memberMike)

    assert_no_difference -> { Category.count } do
      post categories_path, params: { group_id: groups(:publicGroup).id,
                                      name: "cool category" }
    end
  end

  test "non-group memebers cannot add categories" do
    sign_in users(:loserLarry)

    assert_no_difference -> { Category.count } do
      post categories_path, params: { group_id: groups(:publicGroup).id,
                                      name: "cool category" }
    end
  end

  test "group owner can delete categories" do
    sign_in users(:ownerAlice)

    assert_difference -> { Category.count }, -1 do
      delete category_path(categories(:groupCategory))
    end
  end

  test "group moderator can delete categories" do
    sign_in users(:moderatorMaven)

    assert_difference -> { Category.count }, -1 do
      delete category_path(categories(:groupCategory))
    end
  end

  test "group memeber cannot delete categories" do
    sign_in users(:memberMike)

    assert_no_difference -> { Category.count } do
      delete category_path(categories(:groupCategory))
    end
  end

  test "non-group member cannot delete categories" do
    sign_in users(:loserLarry)

    assert_no_difference -> { Category.count } do
      delete category_path(categories(:groupCategory))
    end
  end
end
