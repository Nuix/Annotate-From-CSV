# Matches items based on their associated document ID
class DocumentIDMatcher < CSVMatcherBase
  # Returns true if this matcher should take ownership of a given column based upon
  # that columns header value
  def self.your_header?(header)
    header =~ /^MatchDocumentID$/
  end

  # This method returns the items this matcher matches against given a particular row's value
  def obtain_items(column_value, nuix_case)
    # Run a search for the given document id
    nuix_case.search("document-id:#{column_value}")
  end

  def to_s
    'Document ID Matcher'
  end
end
