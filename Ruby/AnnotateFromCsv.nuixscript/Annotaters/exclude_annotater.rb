# Excludes items with exclusion name based on row value
class ExcludeAnnotater < CSVAnnotaterBase
  # Returns true if this annotater should take ownership of a given column based upon
  # that columns header value
  def self.your_header?(header)
    header =~ /^Exclude$/
  end

  # This method takes the items found by some matcher and performs the relevant annotation on them
  def perform_annotation(items, column_value, _nuix_case)
    # Only exclude items if column had a value
    return if column_value.strip.empty?

    $utilities.getBulkAnnotater.exclude(column_value, items)
  end

  def to_s
    'Exclude'
  end
end
