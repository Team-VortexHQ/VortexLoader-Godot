extends Node

@onready var ver = $Version
@onready var load = $LoadButton
@onready var VR = $VR
var curVer = "V1.0"
var path = ""
var vrchatExc = ""
var file_dialog : FileDialog

# Called when the node enters the scene tree for the first time.
func _ready():
	ver.text = curVer
	path = get_vrchat_path()
	vrchatExc = path + "\\VRChat.exe"

	# Create and configure the FileDialog
	file_dialog = FileDialog.new()
	add_child(file_dialog)
	
	# Set the filter for file types (in this case, "*.vrcw")
	file_dialog.filters = ["*.vrcw"]
	
	# Connect the signal correctly (using Callable(self, method_name))
	file_dialog.connect("file_selected", Callable(self, "_on_file_selected"))  # Correct usage
	
	# Connect the VR button press
	VR.connect("pressed",Callable(self, "_on_VR_pressed"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if vrchatExc != "":
		if VR.pressed:
			vrchatExc += " --no-vr"
		if load.action_mode == 0:
			# Open the file dialog when the load button is pressed
			# Debug: Ensure that the condition is met and check the console if it's being triggered
			print("Trying to open file dialog")
			file_dialog.popup_centered()

# Signal handler for the VR button
func _on_VR_pressed():
	print("VR Button Pressed!")
	# Handle VR button press logic here

# Signal handler for the file selection
func _on_file_selected(path: String):
	print("File selected: ", path)
	# Handle the selected file path, for example:
	# You could load or process the `.vrcw` file here
	vrchatExc = path  # Assign the selected file to the vrchatExc variable

func get_vrchat_path() -> String:
	var result = []
	var error = OS.execute("reg", ["query", "HKCU\\Software\\VRChat"], result, true)
	
	if error == OK:
		if result.size() == 0:
			print("No output from registry query.")
			return ""  # Return an empty string if no result is found
		else:
			for line in result:
				if line.begins_with("(Default)"):
					var vrchat_path = line.split("    ")[-1].strip_edges()  # Extract and clean up the path
					return vrchat_path  # Return the VRChat path
	else:
		print("Error accessing registry: ", error)
	
	return ""  # Ensure that an empty string is returned if there was an issue
