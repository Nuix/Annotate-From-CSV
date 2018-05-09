# Removes tag from items with the name of the tag being removed based on the row value
class RemoveTagsAnnotater < CSVAnnotaterBase
  # Returns true if this annotater should take ownership of a given column based upon
  # that columns header value
  def self.your_header?(header)
    header =~ /^RemoveTags$/
  end

  # This method takes the items found by some matcher and performs the relevant annotation on them
  def perform_annotation(items, column_value, _nuix_case)
    # Split column value by ;, trim whitespace and dump empty entries
    # to get the series of tags to be applied
    tags = column_value.split(';').map(&:strip)
    # Remove each tag (if any)
    tags.each do |tag|
      AnnotationCSVParser.log("Removing tag #{tag} from #{items.size} items")
      $utilities.getBulkAnnotater.removeTag(tag, items)
    end
  end

  def to_s
    'Remove Tags'
  end
end
