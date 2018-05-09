# Tags items with a tag based on value in row
class AddTagsAnnotater < CSVAnnotaterBase
  @@header_regex = /^AddTags$/

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
    # Split column value by ;, trim whitespace and dump empty entries
    # to get the series of tags to be applied
    tags = column_value.split(";").map{|t|t.strip}.reject{|t|t.empty?}
    # Apply each tag (if any)
    tags.each do |tag|
      AnnotationCSVParser.log("Adding tag #{tag} to #{items.size} items")
      $utilities.getBulkAnnotater.addTag(tag, items)
    end
  end

  def to_s
    return "Add Tags"
  end
end