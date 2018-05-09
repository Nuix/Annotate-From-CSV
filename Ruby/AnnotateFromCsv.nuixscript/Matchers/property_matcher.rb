# Matches items by property value
class PropertyMatcher < CSVMatcherBase
  def initialize(utilities, header, col_index)
    super(utilities, header, col_index)

    @property_name = header.gsub(@@header_regex, '\\1')
  end

  # Returns true if this matcher should take ownership of a given column based upon
  # that columns header value
  def self.your_header?(header)
    header =~ /^MatchProperty:(.*)$/
  end

  # This method returns the items this matcher matches against given a particular row's value
  def obtain_items(column_value, nuix_case)
    # Run a search for the given property
    items = nuix_case.search("properties:\"#{@property_name}:#{column_value}\"")
    # Further refine matches to only items where the given property contains the exact
    # specified value
    items.select do |item|
      next item.getProperties[@property_name] == column_value
    end
  end

  def to_s
    'Property Matcher'
  end
end
