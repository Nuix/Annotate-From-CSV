Annotate from CSV
=================

![Last tested in Nuix 7.4](https://img.shields.io/badge/Nuix-7.4-green.svg)

View the GitHub project [here](https://github.com/Nuix/Annotate-From-CSV) or download the latest release [here](https://github.com/Nuix/Annotate-From-CSV/releases).

# Overview

This script allows you to apply annotations to a Nuix case based on a specially formatted input CSV.  Supported annotation operations include:

- Add/Remove Tags
- Set/Append Comments
- Exclude Items
- Assign Custodians

# Getting Started

## Setup

Begin by downloading the latest release.  Extract the folder `AnnotateFromCsv.nuixscript` and its contents from the archive into your Nuix scripts directory.  In windows this directory is likely going to be either of the following:

- `%appdata%\Nuix\Scripts` - User level script directory
- `%programdata%\Nuix\Scripts` - System level script directory

## Input CSV Format

The input CSV uses a series of specially named column headers that dictate how to find the items for a given row and what annotations to apply to those matched items for the row.

### Matchers

For each row read from the input CSV, matcher columns are checked from left to right, using results from the first matcher column which is not empty and yields items when searched for.  Each input CSV must have at least one of the matcher columns, but is not required to have all matcher columns.

**Note**: Column headers are case sensitive!

| Column Header Format |Description   |
|--|--|
| `MatchQuery` | Matches items which are responsive to the given search query. |
| `MatchQueryTopLevel` | Similar to `MatchQuery`, will run the given search query, but this matcher will yield the top level items of the search hits. |
| `MatchQueryFamilies` | Similar to `MatchQuery`, will run the given search query, but this matcher will yield the entire families of the search hits. |
| `MatchQueryDescendants` | Similar to `MatchQuery`, will run the given search query, but this matcher will yield only the descendants of the search hits. |
| `MatchGUID` | Matches items with the given GUID value. |
| `MatchKind` | Matches items with the given kind value. |
| `MatchMD5` | Matches items with the given MD5 value. |
| `MatchDocumentID` | Matches items with the given document id value. |
| `MatchProperty:<NAME>` | Matches items which have the property `<NAME>` with the given value.  Property matching is performed in two ways.  First by searching for `properties:"<NAME>:<COLUMN_VALUE>"`.  For each of the items responsive to that search, the items are further filtered to ensure that each item has the exact specified value for the specified property. |
| `MatchCustomMetadata:<NAME>` | Matches items which have the custom metadata field `<NAME>`.  Custom metadata matching is performed in two ways.  First by searching for `custom-metadata:"<NAME>":"<COLUMN_VALUE>"`.  For each of the items responsive to that search, the items are further filtered to ensure that each item has the exact specified value. |

### Annotaters

Once a matcher has obtained items for a given row, each annotater column is ran against the obtained items.

**Note**: Column headers are case sensitive!
**Note**: When an annotater column's value is empty for a given row, it will perform no action for that row!

| Column Header Format | Description |
|----------------------|-------------|
| `AddTags` | Adds tags based on column value for the given row to matched items.  Multiple tags may be specified by using `;` as a delimiter. |
| `RemoveTags` | Removes tags based on column value for the given row from matched items.  Multiple tags may be specified by using `;` as a delimiter. |
| `AssignCustodian` | Assigns a custodian based on the column value for the given row to matched items. |
| `Exclude` | Excludes matched items into an exclusion named after the column value for the given row. |
| `AppendComment` | Appends a comment to any existing comments on the matched items based on the column value for the given row.  Will set the comment for any items which do not already have a comment. |
| `SetComment` | Sets a comment on matched items.  **Note:** that any existing comment on the matched items will be overwritten. |
| `SetCustomMetadata:<NAME>` | Sets a custom metadata on matched items with a field named `<NAME>` and a value based on the column value for the given row.  **Note:** that existing values in the specified custom metdata field on the matched items will be overwritten! |

# Extending

Matchers and annotaters are defined by creating a class implementing the appropriate class and placing it in either the "Matchers" or "Annotaters" sub directory of the script.

## Custom Matchers

To create a custom matcher you must create a class which derives from the `CSVMatcherBase` class and save it in the "Matchers" sub directory of the script.  The matcher class takes the basic form:

```ruby
class MyCustomMatcher < CSVMatcherBase
	# Regex used to identify this matchers column header
	@@header_regex = /^MyCustomMatcher$/

	# When matcher is created it is provided header and column index
	# @col_index must be set to the column index to function properly later
	def initialize(header,col_index)
		@col_index = col_index
	end

	# This method will be called to determine if it is the appropriate matcher
	# for a given column.  This is where the header is analyzed to determine if
	# this matcher is appropriate.  Usually checking the regex above against
	# the header name is enough.
	def self.is_your_header?(header)
		return header =~ @@header_regex
	end

	# This method is called when a given row has a value for the given column.
	# This method recieves the given column's value and the nuix_case being operated on.
	# This method should return a collection of items.  If the array size is less than 1
	# the next matcher in the CSV will be tested.
	def obtain_items(column_value,nuix_case)
		items = nuix_case.search(column_value)
		return items
	end

	# Should return a descriptive string of what this matcher is.
	def to_s
		return "My Custom Matcher"
	end
end
```

The best way to get a sense of how matchers work is to review some of the existing ones provided with the script in the "Matchers" sub directory.

## Custom Annotaters

To create a custom annotater you must create a class which derives from the `CSVAnnotaterBase` class and save it in the "Annotaters" sub directory of the script.  The annotater class takes the basic form:

```ruby
class MyCustomAnnotater < CSVAnnotaterBase
	# Regex used to identify this annotaters column header
	@@header_regex = /^MyCustomAnnotater$/

	# When annotater is created it is provided header and column index.
	# @col_index must be set to the column index to function properly later
	def initialize(header,col_index)
		@col_index = col_index
	end

	# This method will be called to determine if it is the appropriate matcher
	# for a given column.  This is where the header is analyzed to determine if
	# this matcher is appropriate.  Usually checking the regex above against
	# the header name is enough.
	def self.is_your_header?(header)
		return header =~ @@header_regex
	end

	# This method is called when a given row has a value for the given column.
	# This methods receives the items yielded by a matcher, the given column's value
	# and the nuix_case being operated on.  This method is where the actual annotation
	# actions occur.
	def perform_annotation(items,column_value,nuix_case)
		$utilities.getBulkAnnotater.addTag(column_value,items)
	end

	# Should return a descriptive string of what this annotater is.
	def to_s
		return "My Custom Annotater"
	end
end
```

The best way to get a sense of how annotaters work is to review some of the existing ones provided with the script in the "Annotaters" sub directory.

# License

```
Copyright 2018 Nuix

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

# Icon Credit

```
Silk icon set 1.3

_________________________________________
Mark James
http://www.famfamfam.com/lab/icons/silk/
_________________________________________

This work is licensed under a
Creative Commons Attribution 2.5 License.
[ http://creativecommons.org/licenses/by/2.5/ ]

This means you may use it for any purpose,
and make any changes you like.
All I ask is that you include a link back
to this page in your credits.
```
