require 'search_scoring'

class SearchScoringTest < ActiveSupport::TestCase
  test "rank sorts by name properly" do
    # obviously different search query should score lower
    assert_operator SearchScore.by_name("Bob Marley", "Xi Jinping"),
                    :<,
                    SearchScore.by_name("Bob Marley", "Bob")

    # first name is a better match than last name
    assert_operator SearchScore.by_name("Bob Marley", "Bob"),
                    :>,
                    SearchScore.by_name("Bob Marley", "Marley")
  end
end