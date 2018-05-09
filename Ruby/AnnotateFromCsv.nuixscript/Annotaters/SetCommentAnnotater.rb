# Sets/overwrites existing comments with new comment based on row value
class SetCommentAnnotater < CSVAnnotaterBase
  @@header_regex = /^SetComment$/

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
    # Set comment if column had a value
    if !column_value.strip.empty?
      items.each do |item|
        item.setComment(column_value)
      end
    end
  end

  def to_s
    return "Set Comment"
  end
end