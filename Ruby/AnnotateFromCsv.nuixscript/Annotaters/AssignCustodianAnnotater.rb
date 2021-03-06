# Assigns custodian to items based on row value
class AssignCustodianAnnotater < CSVAnnotaterBase
	@@header_regex = /^AssignCustodian$/

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
		# Only assign custodian if column had a value
		if !column_value.strip.empty?
			AnnotationCSVParser.log("Assigning custodian '#{column_value}' to #{items.size} items")
			$utilities.getBulkAnnotater.assignCustodian(column_value,items)
		end
	end

	def to_s
		return "Assign Custodian"
	end
end