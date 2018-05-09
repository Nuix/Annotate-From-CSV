# Removes tag from items with the name of the tag being removed based on the row value
class RemoveTagsAnnotater < CSVAnnotaterBase
  @@header_regex = /^RemoveTags$/

  def initialize(header,col_index)
    @col_index = col_index
  end

  # Returns true if this annotater should take ownership of a given column based upon
  # that columns header value
  def self.is_your_header?(header)
    return header =~ @@header_regex
  end

  # This method takes the items found by some matcher and performs the relevant annotation on them
  def perform_annotation(items,column_value,nuix_case)
    # Split column value by ;, trim whitespace and dump empty entries
    # to get the series of tags to be applied
    tags = column_value.split(";").map{|t|t.strip}
    # Remove each tag (if any)
    tags.each do |tag|
      AnnotationCSVParser.log("Removing tag #{tag} from #{items.size} items")
      $utilities.getBulkAnnotater.removeTag(tag,items)
    end
  end

  def to_s
    return "Remove Tags"
  end
end