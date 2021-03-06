# Matches items based on a value in a specified custom metadata field
class CustomMetadataMatcher < CSVMatcherBase
	# Regular expression used to recognize columns handled by this matcher
	@@header_regex = /^MatchCustomMetadata:(.*)$/
	
	@field_name = nil

	def initialize(header,col_index)
		@col_index = col_index
		@field_name = header.gsub(@@header_regex,"\\1")
	end

	# Returns true if this matcher should take ownership of a given column based upon
	# that columns header value
	def self.is_your_header?(header)
		return header =~ @@header_regex
	end

	# This method returns the items this matcher matches against given a particular row's value
	def obtain_items(column_value,nuix_case)
		# Get intial items which match a custom metadata search
		query = "custom-metadata:\"#{@field_name}\":\"#{column_value}\""
		AnnotationCSVParser.log("Obtaining items based on custom metadata...")
		items = nuix_case.search(query)
		# Further validate each hit actually matches
		items = items.select do |item|
			next (item.getCustomMetadata[@field_name] || "").to_s == column_value
		end
	end

	def to_s
		return "Custom Metadata  Matcher"
	end
end