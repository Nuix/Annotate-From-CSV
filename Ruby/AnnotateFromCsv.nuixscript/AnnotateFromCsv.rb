# Bootstrap the Nx library
script_directory = File.dirname(__FILE__)
require File.join(script_directory,"Nx.jar")
java_import "com.nuix.nx.NuixConnection"
java_import "com.nuix.nx.LookAndFeelHelper"
java_import "com.nuix.nx.dialogs.ChoiceDialog"
java_import "com.nuix.nx.dialogs.TabbedCustomDialog"
java_import "com.nuix.nx.dialogs.CommonDialogs"
java_import "com.nuix.nx.dialogs.ProgressDialog"
java_import "com.nuix.nx.digest.DigestHelper"
java_import "com.nuix.nx.controls.models.Choice"

LookAndFeelHelper.setWindowsIfMetal
NuixConnection.setUtilities($utilities)
NuixConnection.setCurrentNuixVersion(NUIX_VERSION)

# Load dependencies
load File.join(script_directory,"AnnotationCsvParser.rb")

# Construct settings dialog
dialog = TabbedCustomDialog.new("Annotate from CSV")
dialog.setHelpFile(File.join(script_directory,"Readme.html"))
main_tab = dialog.addTab("main_tab","Main")
main_tab.appendOpenFileChooser("input_csv","Input CSV","Comma Separated Values","csv")

# Display settings dialog
dialog.display

# If settings are valid and user clicked OK lets proceed
if dialog.getDialogResult == true
	# Get settings from settings dialog
	values = dialog.toMap

	# Extract settings from hash into variables for convenience
	input_csv = values["input_csv"]

	# Display a progress dialog while we do the work
	ProgressDialog.forBlock do |pd|
		# Set progress dialog title
		pd.setTitle("Annotate from CSV")

		# Disable abort button
		pd.setAbortButtonVisible(false)

		# Connect up parser callback so messages it logs will be displayed
		# in the progress dialog's log area and to the script console in Nuix
		AnnotationCSVParser.when_message_logged do |message|
			pd.logMessage(message)
			puts message
		end

		# Connect up parser callback so progress updates are reported to the
		# progress dialog
		AnnotationCSVParser.when_progress_updated do |current,total|
			pd.setMainStatus("Processing row #{current+1}/#{total}")
			pd.logMessage("===== Processing row #{current+1}/#{total} =====")
			pd.setMainProgress(current+1,total)
		end

		# Begin processing the CSV
		AnnotationCSVParser.process_csv(input_csv)

		# Set progress dialog to a completed state
		pd.setCompleted
	end
end