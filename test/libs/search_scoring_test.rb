require 'test_helper'
require 'search_scoring'

class SearchScoringTest < ActiveSupport::TestCase
  test "#name works" do
    query = "donald"
    names = [
      "Lily McDonald",
      "Donald Jones",
      "Jones Donald",
      "Donald",
      "Xi Jinping"
    ]

    ranked_names = names.sort_by { |name| SearchScore.name(name, query) }
    expected_order = [
      "Donald",
      "Donald Jones",
      "Jones Donald",
      "Lily McDonald",
      "Xi Jinping"
    ]

    assert_equal expected_order, ranked_names
  end
end
