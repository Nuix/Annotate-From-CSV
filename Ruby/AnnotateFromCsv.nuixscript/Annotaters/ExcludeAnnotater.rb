# Excludes items with exclusion name based on row value
class ExcludeAnnotater < CSVAnnotaterBase
  @@header_regex = /^Exclude$/

  def initialize(header, col_index)
    @col_index = col_index
  end

  # Returns true if this annotater should take ownership of a given column based upon
  # that columns header value
  def self.is_your_header?(header)
    return header =~ @@header_regex
  end

  # This method takes the items found by some matcher and performs the relevant annotation on them
  def perform_annotation(items, column_value, nuix_case)
    # Only exclude items if column had a value
    if !column_value.strip.empty?
      $utilities.getBulkAnnotater.exclude(column_value, items)
    end
  end

  def to_s
    return "Exclude"
  end
end