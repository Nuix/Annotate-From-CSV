# Matches items by query
class QueryMatcher < CSVMatcherBase
	# Regular expression used to recognize columns handled by this matcher
	@@header_regex = /^MatchQuery$/

	def initialize(header,col_index)
		@col_index = col_index
	end

	# Returns true if this matcher should take ownership of a given column based upon
	# that columns header value
	def self.is_your_header?(header)
		return header =~ @@header_regex
	end

	# This method returns the items this matcher matches against given a particular row's value
	def obtain_items(column_value,nuix_case)
		# Run search based on given column value
		AnnotationCSVParser.log("Obtaining query hits...")
		return nuix_case.search(column_value)
	end

	def to_s
		return "Query Matcher"
	end
end