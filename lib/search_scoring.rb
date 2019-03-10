module SearchScore
  # Returns a number. Lower numbers indicate a stronger match.
  def self.name(name, query)
    # Lowercase the name and the query
    name = name.downcase
    query = query.downcase

    # Split the name into words so we can easily check for full matches on
    # middle or last names
    name_words = name.split(' ');

    # prioritize EXACT matches to the WHOLE name
    return 0 if name == query

    # then EXACT matches on the FIRST name
    return 1 if name_words[0] === query

    # then EXACT matches on MIDDLE/LAST name
    return 2 if name_words.include?(query)

    # then PARTIAL starting matches on the FIRST name
    return 3 if name.start_with?(query)

    # then PARTIAL starting matches on the MIDDLE/LAST name
    return 4 if name.include?(" " + query)

    # then general PARTIAL matches
    return 5 if name.include?(query)

    # it's a non-match so return a really high number
    10
  end
end
