# Matches items by query, returning their associated top level items
class QueryTopLevelMatcher < CSVMatcherBase
  # Returns true if this matcher should take ownership of a given column based upon
  # that columns header value
  def self.your_header?(header)
    header =~ /^MatchQueryTopLevel$/
  end

  # This method returns the items this matcher matches against given a particular row's value
  def obtain_items(column_value, nuix_case)
    # Run search based on given column value
    items = nuix_case.search(column_value)
    # Resolve to top level items
    utilities.getItemUtility.findTopLevelItems(items)
  end

  def to_s
    'Query Top Level Matcher'
  end
end
