# Matches item by kind
class KindMatcher < CSVMatcherBase
  # Returns true if this matcher should take ownership of a given column based upon
  # that columns header value
  def self.your_header?(header)
    header =~ /^MatchKind$/
  end

  # This method returns the items this matcher matches against given a particular row's value
  def obtain_items(column_value, nuix_case)
    # Run a search for the given kind
    nuix_case.search("kind:#{column_value}")
  end

  def to_s
    'Kind Matcher'
  end
end
