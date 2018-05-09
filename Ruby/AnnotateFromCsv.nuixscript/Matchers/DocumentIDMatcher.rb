# Matches items based on their associated document ID
class DocumentIDMatcher < CSVMatcherBase
  # Regular expression used to recognize columns handled by this matcher
  @@header_regex = /^MatchDocumentID$/

  def initialize(header, col_index)
    @col_index = col_index
  end

  # Returns true if this matcher should take ownership of a given column based upon
  # that columns header value
  def self.is_your_header?(header)
    return header =~ @@header_regex
  end

  # This method returns the items this matcher matches against given a particular row's value
  def obtain_items(column_value, nuix_case)
    # Run a search for the given document id
    return nuix_case.search("document-id:#{column_value}")
  end

  def to_s
    return "Document ID Matcher"
  end
end