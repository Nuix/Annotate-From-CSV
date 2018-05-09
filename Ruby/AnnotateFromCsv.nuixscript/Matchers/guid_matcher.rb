# Matches items based on their GUID
class GUIDMatcher < CSVMatcherBase
  # Returns true if this matcher should take ownership of a given column based upon
  # that columns header value
  def self.your_header?(header)
    header =~ /^MatchGUID$/
  end

  # This method returns the items this matcher matches against given a particular row's value
  def obtain_items(column_value, nuix_case)
    # Run a search for the given GUID
    nuix_case.search("guid:#{column_value}")
  end

  def to_s
    'GUID Matcher'
  end
end
