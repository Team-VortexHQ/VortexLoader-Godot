extends Node

@onready var ver = $Version
@onready var load = $LoadButton
@onready var open = $Open
@onready var VR = $VR
@onready var wrld = $World
var curVer = "V1.0"
var path = ""
var vrchatExc = ""
var novr = ""
var worldPath = ""
var vrcwpath = ""
var file_dialog : FileDialog

func _ready():
	ver.text = curVer
	path = get_vrchat_path()
	vrchatExc = path
	load.connect("pressed",Callable(self, "open_file_dialog"))
	open.connect("pressed", Callable(self, "open_vrc"))

	VR.connect("pressed",Callable(self, "_on_VR_pressed"))

func _process(delta):
	if vrchatExc != "":
		if !VR.pressed:
			novr = " --no-vr"			
		else:
			novr = " "
		if load.action_mode == 0:
			open_file_dialog()

func _on_file_selected(path: String):
	vrchatExc = path  

func get_vrchat_path() -> String:

	var steam_path_result = []
	var steam_reg_error = OS.execute("reg", ["query", "HKLM\\SOFTWARE\\WOW6432Node\\Valve\\Steam", "/v", "InstallPath"], steam_path_result, true)

	if steam_reg_error != OK:
		print("Error accessing Steam registry key.")
		return ""

	var steam_path = ""
	for line in steam_path_result:
		if "REG_SZ" in line:
			steam_path = line.split("REG_SZ")[-1].strip_edges()
			break

	if steam_path == "":
		print("Steam install path not found in registry.")
		return ""

	var library_file = steam_path + "\\steamapps\\libraryfolders.vdf"
	if not FileAccess.file_exists(library_file):
		print("Steam libraryfolders.vdf not found.")
		return ""

	var file = FileAccess.open(library_file, FileAccess.READ)
	if file == null:
		print("Failed to open Steam libraryfolders.vdf.")
		return ""

	var vdf_content = file.get_as_text()
	file.close()

	var regex = RegEx.new()
	regex.compile('"path"\\s+"([^"]+)"')
	var matches = regex.search_all(vdf_content)

	var potential_paths = []

	for match in matches:
		var library_path = match.get_string(1).replace("\\\\", "\\")  
		var vrchat_path = library_path + "\\steamapps\\common\\VRChat\\VRChat.exe"
		if FileAccess.file_exists(vrchat_path):
			print("VRChat found at:", vrchat_path)
			return vrchat_path
		else:
			potential_paths.append(vrchat_path)

	print("VRChat executable not found in any Steam library folder. Checked paths:", potential_paths)
	return ""

func open_file_dialog():
	wrld.visible = true

func _on_world_file_selected(path: String):
	if path.is_empty():
		print("Error: No world file selected!")
		return

	print("Selected path:", path)  
	worldPath = path
	var random_room_id = str(rand_count(10))
	vrcwpath = '--url=create?roomId=' + random_room_id + '&hidden=true&name=BuildAndRun&url=file:///' + worldPath.replace("\\", "/") + novr
	print("Generated VRChat URL:", vrcwpath)

func open_vrc():
	if vrcwpath == "":
		print("Error: vrcwpath is empty!")
		return

	var args = [vrcwpath]
	var result = OS.execute(vrchatExc, args)
	
	if result != 0:
		print("Failed to launch VRChat! Error code:", result)
	else:
		print("VRChat launched successfully!")
		get_tree().quit()

func rand_count(num:int):
	var nums = []
	var final_num:String = ""
	for i in range(num):
		nums.append(randi_range(0,10))
		final_num += str(nums[i])
	return final_num
