# Tags items with a tag based on value in row
class AddTagsAnnotater < CSVAnnotaterBase
  # Returns true if this annotater should take ownership of a given column based upon
  # that columns header value
  def self.your_header?(header)
    header =~ /^AddTags$/
  end

  # This method takes the items found by some matcher and performs the relevant annotation on them
  def perform_annotation(items, column_value, _nuix_case)
    # Split column value by ;, trim whitespace and dump empty entries
    # to get the series of tags to be applied
    tags = column_value.split(';').map(&:strip).reject(&:empty?)
    # Apply each tag (if any)
    tags.each do |tag|
      AnnotationCSVParser.log("Adding tag #{tag} to #{items.size} items")
      $utilities.getBulkAnnotater.addTag(tag, items)
    end
  end

  def to_s
    'Add Tags'
  end
end
