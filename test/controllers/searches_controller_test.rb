require 'test_helper'

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
    get users_search_path, params: { q: "viktor" }, as: :json

    assert_includes @response.body, "Viktor"
  end

  test "#users search doesn't find non-existent users" do
    get users_search_path, params: { q: "$$$$" }, as: :json

    assert_equal "[]", @response.body, "expected empty array"
  end

  test "#all search finds user" do
    get all_search_path, params: { q: "viktor" }, as: :json

    assert_includes @response.body, "Viktor"
  end

  test "#all search finds group" do
    get all_search_path, params: { q: "LazyGroup" }, as: :json

    assert_includes @response.body, "LazyGroup"
  end

  test "#group_invitable_users_search shows invitable users" do
    get group_invitable_users_search_path,
        params: { group_id: groups(:one).id, q: "joe" },
        as: :json

    assert_includes @response.body, "Joe"
  end

  test "#group_invitable_users_search does not show existing group members" do
    get group_invitable_users_search_path,
        params: { group_id: groups(:one).id, q: "viktor" },
        as: :json

    assert_not_includes @response.body, "Viktor"
  end
end
