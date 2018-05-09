# Matches items based on a value in a specified custom metadata field
class CustomMetadataMatcher < CSVMatcherBase
  def initialize(header, col_index)
    super(header, col_index)

    @field_name = header.gsub(@@header_regex, '\\1')
  end

  # Returns true if this matcher should take ownership of a given column based upon
  # that columns header value
  def self.your_header?(header)
    header =~ /^MatchCustomMetadata:(.*)$/
  end

  # This method returns the items this matcher matches against given a particular row's value
  def obtain_items(column_value, nuix_case)
    # Get intial items which match a custom metadata search
    items = nuix_case.search("custom-metadata:\"#{@field_name}\":\"#{column_value}\"")
    # Further validate each hit actually matches
    items.select do |item|
      next (item.getCustomMetadata[@field_name] || '').to_s == column_value
    end
  end

  def to_s
    'Custom Metadata Matcher'
  end
end
