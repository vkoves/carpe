module SearchScore
  # Returns a number. Higher numbers indicate the search
  # string strongly matches the given name.
  def self.by_name(name, query)
    # prioritize matches on the first name
    return 2 if name.starts_with?(query)

    # then matches on the middle/last name
    return 1 if name.include?(" " + query)

    # ¯\_(ツ)_/¯ not today, buddy
    return 0
  end
end