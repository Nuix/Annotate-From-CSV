# Matches items by provided query, returning their descendants
class QueryDescendantMatcher < CSVMatcherBase
  # Regular expression used to recognize columns handled by this matcher
  @@header_regex = /^MatchQueryDescendants$/

  def initialize(header, col_index)
    @col_index = col_index
  end

  # Returns true if this matcher should take ownership of a given column based upon
  # that columns header value
  def self.is_your_header?(header)
    header =~ @@header_regex
  end

  # This method returns the items this matcher matches against given a particular row's value
  def obtain_items(column_value, nuix_case)
    # Run search based on given column value
    items = nuix_case.search(column_value)
    # Resolve to descendants
    $utilities.getItemUtility.findDescendants(items)
  end

  def to_s
    "Query Descendant Matcher"
  end
end