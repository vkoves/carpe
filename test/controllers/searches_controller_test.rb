require "test_helper"

class SearchesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    sign_in users(:viktor)
  end

  test "empty search queries return no results" do
    get users_search_path, params: { q: "" }, as: :json

    assert_equal "[]", @response.body, "expected empty array"
  end

  test "#users search finds users" do
    name = users(:viktor).name

    get users_search_path, params: { q: name }, as: :json

    assert_includes @response.body, name
  end

  test "#users search doesn't find non-existent users" do
    get users_search_path, params: { q: "$$$$" }, as: :json

    assert_equal "[]", @response.body, "expected empty array"
  end

  test "#all search finds user" do
    name = users(:viktor).name # => Viktor
    query = name[0..2] # => Vik

    get all_search_path, params: { q: query }, as: :json

    assert_includes @response.body, name
  end

  test "#all search finds group" do
    name = groups(:one).name

    get all_search_path, params: { q: name }, as: :json

    assert_includes @response.body, name
  end

  test "#group_invitable_users_search shows invitable users" do
    name = users(:joe).name # => Joe joe
    query = name[0..2] # => Joe

    get group_invitable_users_search_path,
        params: { group_id: groups(:one).id, q: query },
        as: :json

    assert_includes @response.body, name
  end

  test "#group_invitable_users_search does not show existing group members" do
    name = users(:viktor).name # => Viktor
    query = name[0..2] # => Vik

    get group_invitable_users_search_path,
        params: { group_id: groups(:one).id, q: query },
        as: :json

    assert_not_includes @response.body, name
  end
end
