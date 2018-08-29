require 'test_helper'
require 'search_scoring'

class SearchScoringTest < ActiveSupport::TestCase
  test "#name works" do
    names = ["Lily McDonald", "Donald Jones", "Jones Donald", "Xi Jinping"]
    query = "donald"

    ranked_names = names.sort_by { |name| SearchScore.name(name, query) }
    assert_equal ["Donald Jones", "Jones Donald", "Lily McDonald", "Xi Jinping"],
                 ranked_names
  end
end
