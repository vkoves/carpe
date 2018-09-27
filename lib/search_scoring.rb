module SearchScore
  # Returns a number. Lower numbers indicate a stronger match.
  def self.name(name, query)
    name = name.downcase
    query = query.downcase

    # prioritize exact matches
    return 0 if name == query

    # then matches on the first name
    return 1 if name.include?(query + " ")

    # then matches on the middle/last name
    return 2 if name.include?(" " + query)

    # then on general, partial matches
    return 3 if name.include?(query)

    # ¯\_(ツ)_/¯ it's a poor match
    return 4
  end
end
