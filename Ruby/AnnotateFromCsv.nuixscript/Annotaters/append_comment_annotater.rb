# Appends row value to comment field of items
class AppendCommentAnnotater < CSVAnnotaterBase
  @@header_regex = /^AppendComment$/

  # Returns true if this annotater should take ownership of a given column based upon
  # that columns header value
  def self.your_header?(header)
    header =~ @@header_regex
  end

  # This method takes the items found by some matcher and performs the relevant annotation on them
  def perform_annotation(items, column_value, _nuix_case)
    # Only append comment if column contained a value
    return if column_value.strip.empty?

    items.each do |item|
      item.appendComment(column_value)
    end
  end

  def to_s
    'Append Comment'
  end
end
