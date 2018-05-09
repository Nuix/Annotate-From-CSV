require 'csv'

# Base class for matchers
class CSVMatcherBase
  attr_reader :utilities
  attr_reader :col_index

  def initialize(utilities, _header, col_index)
    @utilities = utilities
    @col_index = col_index
  end
end

# Base class for annotaters
class CSVAnnotaterBase
  attr_reader :utilities
  attr_reader :col_index

  def initialize(utilities, _header, col_index)
    @utilities = utilities
    @col_index = col_index
  end
end

# Parses a CSV, constructing matchers and parsers based on headers
class AnnotationCSVParser
  attr_accessor :matchers
  attr_accessor :annotaters
  attr_accessor :remove_excluded_items

  def initialize
    @matchers = []
    @annotaters = []
    @remove_excluded_items = true
  end

  # Processes a single record from the CSV
  def process_record(record_values, row_index, nuix_case)
    # Determine matcher for this row
    items = nil
    matchers.each do |matcher|
      column_value = (record_values[matcher.col_index] || '').strip
      next if column_value.empty?

      items = matcher.obtain_items(column_value, nuix_case)
      break unless items.empty?
    end

    # If we obtained items, run each annotater
    if items.nil?
      AnnotationCSVParser.log "Row #{row_index + 1}: No matcher columns had a value or yielded any items"
    else
      # Some matcher was able to give us some items
      items = items.reject(&:excluded?) if @remove_excluded_items

      if items.empty?
        AnnotationCSVParser.log 'After removing excluded items, 0 items remain, moving on...'
      else
        annotaters.each do |annotater|
          column_value = record_values[annotater.col_index] || ''
          annotater.perform_annotation(items, column_value, nuix_case)
        end
      end
    end
  end

  # Allows code to listen for progress updates
  def self.when_progress_updated(&block)
    @progress_updated_callback = block
  end

  # Broadcasts progress updates to callback if registered
  def self.update_progress(current, total)
    return if @progress_updated_callback.nil?

    @progress_updated_callback.call(current, total)
  end

  # Allows code to listen for log messages
  def self.when_message_logged(&block)
    @message_logged_callback = block
  end

  # Broadcasts log messages to callback if registered
  def self.log(message)
    return if @message_logged_callback.nil?

    @message_logged_callback.call(message)
  end

  # Returns all defined matchers using reflection to locate all classes
  # derived from CSVMatcherBase class
  def self.all_matchers
    ObjectSpace.each_object(Class).select { |klass| klass < CSVMatcherBase }
  end

  # Returns all defined annotaters using reflection to locate all classes
  # derived from CSVAnnotaterBase class
  def self.all_annotaters
    ObjectSpace.each_object(Class).select { |klass| klass < CSVAnnotaterBase }
  end

  # Given array of headers, constructs appropriate matchers and annotaters for which there
  # is a matcher or annotater that accepts responsibility
  def self.build_from_headers(headers, utilities)
    instance = new

    # Log the headers we found
    AnnotationCSVParser.log 'Parsing headers:'
    headers.each do |header|
      AnnotationCSVParser.log "  '#{header}'"
    end

    # Build matchers
    AnnotationCSVParser.log 'Locating matchers...'
    headers.each_with_index do |header, header_index|
      all_matchers.each do |matcher_class|
        next unless matcher_class.your_header?(header)

        matcher_instance = matcher_class.new(utilities, header, header_index)
        instance.matchers << matcher_instance
        AnnotationCSVParser.log "[#{header_index}] Adding Matcher: #{matcher_instance}"
        break
      end
    end

    # Build annotaters
    AnnotationCSVParser.log 'Locating annotaters...'
    headers.each_with_index do |header, header_index|
      all_annotaters.each do |annotater_class|
        next unless annotater_class.your_header?(header)

        annotater_instance = annotater_class.new(utilities, header, header_index)
        instance.annotaters << annotater_instance
        AnnotationCSVParser.log "[#{header_index}] Adding Annotater: #{annotater_instance}"
        break
      end
    end

    # Log our parsing results
    AnnotationCSVParser.log("Located #{instance.matchers.size} matchers")
    AnnotationCSVParser.log("Located #{instance.annotaters.size} annotaters")

    instance
  end

  # Entry point for processing a CSV into a series of annotation operations
  def self.process_csv(csv_path, nuix_case, utilities)
    headers = nil
    parser = nil
    data = []

    # Iterate CSV rows, skimming off headers row which will be used to construct series of
    # matchers and annotaters.  All other rows we will store in an array for their later use.
    CSV.foreach(csv_path) do |row|
      if headers.nil?
        headers = row.reject(&:nil?).map(&:strip).reject(&:empty?)
        parser = build_from_headers(headers, utilities)
      else
        data << row
      end
    end

    # For each non-header row, let the matcher and annotater instances we constructed earlier
    # do their work based on the data present in the given row
    data.each_with_index do |row_values, row_index|
      update_progress(row_index, data.size)
      parser.process_record(row_values, row_index, nuix_case)
    end
  end
end

# With the classes defined above, we can now dynamically load all the matchers and annotaters
# allowing for easy drop in functionality
script_directory ||= File.dirname(__FILE__)
matcher_class_files = Dir.glob("#{script_directory.tr('\\', '/')}/Matchers/**/*.rb")
annotater_class_files = Dir.glob("#{script_directory.tr('\\', '/')}/Annotaters/**/*.rb")
matcher_class_files.each do |matcher_class_file|
  puts "Loading matcher: #{File.basename(matcher_class_file)}"
  load matcher_class_file
end
annotater_class_files.each do |annotater_class_file|
  puts "Loading annotater: #{File.basename(annotater_class_file)}"
  load annotater_class_file
end
