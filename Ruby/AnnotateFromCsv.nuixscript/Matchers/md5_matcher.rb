# Matches items by MD5
class MD5Matcher < CSVMatcherBase
  # Returns true if this matcher should take ownership of a given column based upon
  # that columns header value
  def self.your_header?(header)
    header =~ /^MatchMD5$/
  end

  # This method returns the items this matcher matches against given a particular row's value
  def obtain_items(column_value, nuix_case)
    # Run a search for the given md5
    nuix_case.search("md5:#{column_value}")
  end

  def to_s
    'MD5 Matcher'
  end
end
