java_import org.joda.time.format.DateTimeFormat
java_import org.joda.time.DateTime

class DateFormatPattern
	attr_accessor :format
	attr_accessor :regex

	def initialize(format,regex)
		@format = DateTimeFormat.forPattern(format)
		@regex = regex
		if regex.is_a?(String)
			@regex = /#{regex}/
		end
	end
end

# Sets/overwrites custom meadata field.  Field name based on value provided in header and
# value written to that field based on CSV row value
class SetCustomMetadataAnnotater < CSVAnnotaterBase
	@@header_regex = /^SetCustomMetadata:(.+)$/
	@@number_regex = /^[0-9]+$/
	@@float_regex = /^[0-9]+\.[0-9]+$/
	@@bool_regex = /^(true)|(false)$/i

	# This is where date time pattern recognition is specified.  Adding support for recognizing a new
	# format means adding an additional DateFormatPattern.new(format,regex) below where:
	# format - joda time format string, see for reference https://www.joda.org/joda-time/apidocs/org/joda/time/format/DateTimeFormat.html
	# regex - Used to test a given input to see if it corresponds to a given format
	@@date_time_patterns = [
		DateFormatPattern.new("YYYY-MM-dd HH:mm:ssZZ",/^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}[\+\-][0-9]{2}:[0-9]{2}$/),
	]

	@field_name = nil

	def initialize(header,col_index)
		@col_index = col_index
		@field_name = header.gsub(@@header_regex,"\\1")
	end

	# Returns true if this annotater should take ownership of a given column based upon
	# that columns header value
	def self.is_your_header?(header)
		return header =~ @@header_regex
	end

	# This method takes the items found by some matcher and performs the relevant annotation on them
	def perform_annotation(items,column_value,nuix_case)
		# Only apply a value if the column was not empty
		if !column_value.strip.empty?
			# Analyze the column value to try and determine the data type
			# so that we can apply the custom metadata as a user would expect
			# for example the string "1234" gets stored as the integer 1234
			value_type = nil
			value = nil
			if column_value =~ @@number_regex
				value_type = "integer"
				value = column_value.to_i
			elsif column_value =~ @@float_regex
				value_type = "float"
				value = column_value.to_f
			elsif column_value =~ @@bool_regex
				value_type = "boolean"
				value = column_value.strip.downcase == "true"
			else
				is_date = false
				# Check to see if we recognize this as a valid date format
				@@date_time_patterns.each do |pattern|
					if column_value =~ pattern.regex
						value = DateTime.parse(column_value,pattern.format)
						value_type = "date-time"
						is_date = true
						break
					end
				end

				if !is_date
					value_type = "text"
					value = column_value
				end
			end
			AnnotationCSVParser.log("Applying custom metdata field '#{@field_name}' to #{items.size} items")
			$utilities.getBulkAnnotater.putCustomMetadata(@field_name,value,items,value_type,"user",nil,nil)
		end
	end

	def to_s
		return "Set Custom Metadata: #{@field_name}"
	end
end