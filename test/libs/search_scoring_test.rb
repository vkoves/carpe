require 'test_helper'
require 'search_scoring'

class SearchScoringTest < ActiveSupport::TestCase
  test "#name prioritizes first names" do
    query = "donald"
    good_match = "Donald"
    bad_match = "Donald Vladimir"

    assert_operator SearchScore.name(good_match, query),
                    :<,
                    SearchScore.name(bad_match, query)
  end

  test "#name prioritizes first name" do
    query = "sassy"
    good_match = "Sassy Beaver"
    bad_match = "Beaver Be Sassy"

    assert_operator SearchScore.name(good_match, query),
                    :<,
                    SearchScore.name(bad_match, query)
  end

  test "#name prioritizes middle/last names" do
    query = "flintstone"
    good_match = "Fred Flintstone"
    bad_match = "Natalie Dormer"

    assert_operator SearchScore.name(good_match, query),
                    :<,
                    SearchScore.name(bad_match, query)
  end

  test "#name prioritizes partial matches" do
    query = "uix"
    good_match = "Don Quixote"
    bad_match = "Captain Kirk"

    assert_operator SearchScore.name(good_match, query),
                    :<,
                    SearchScore.name(bad_match, query)
  end

  test "#name ranks bad searches equally" do
    query = "potato"
    bad_match1 = "Alphonse Elric"
    bad_match2 = "Courage The Cowardly Dog"

    assert_equal SearchScore.name(bad_match1, query),
                 SearchScore.name(bad_match2, query)
  end
end
