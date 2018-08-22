class SearchesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  # test "can perform an empty search query" do
  #   get :search, params: { q: nil }
  #   assert_response :success, "Accepts empty search queries"
  # end
  #
  # test "can perform a search query" do
  #   get :search, params: { q: "v" }
  #   assert_response :success
  # end
  #
  # test "can perform a `json` search query" do
  #   get :search, params: { q: "v", format: "json" }
  #   assert_response :success
  # end

  test "search route works" do
    sign_in users(:viktor)
    get users_search_path, xhr: true, params: { q: "vik" }
    assert_response :success
  end
end
