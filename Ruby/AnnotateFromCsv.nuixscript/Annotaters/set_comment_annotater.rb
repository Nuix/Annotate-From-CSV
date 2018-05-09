# Sets/overwrites existing comments with new comment based on row value
class SetCommentAnnotater < CSVAnnotaterBase
  @@header_regex = /^SetComment$/

  # Returns true if this annotater should take ownership of a given column based upon
  # that columns header value
  def self.your_header?(header)
    header =~ @@header_regex
  end

  # This method takes the items found by some matcher and performs the relevant annotation on them
  def perform_annotation(items, column_value, _nuix_case)
    # Set comment if column had a value
    return if column_value.strip.empty?

    items.each do |item|
      item.setComment(column_value)
    end
  end

  def to_s
    'Set Comment'
  end
end
