extends CanvasLayer

@onready var curTheme = preload("res://scenes/theme/Default.tres")
@onready var fps_label = $FPSLabel  # Get the Label node
var font_file : FontFile

func _ready():
	# Create a FontFile and assign a font file to it
	font_file = FontFile.new()
	font_file.font_data = preload("res://assets/fonts/Kallisto Medium.otf")  # Change this path to your font file
	
	# Directly assign the font to the label's font property
	fps_label.push_font(font_file)
	
	# Set initial font size and position
	_update_label()

func _process(delta):
	var fps = Engine.get_frames_per_second()
	var texMem = Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)
	var realMem = Performance.get_monitor(Performance.MEMORY_STATIC)
	
	# Set the text of the label with the FPS
	fps_label.text = " FPS: %d \n VRAM: %s \n Memory: %s" % [fps, String.humanize_size(texMem), String.humanize_size(realMem)]
	#print(fps_label.text)
	# Set the color based on FPS value
	if fps < 30:
		fps_label.add_theme_color_override("font_color", Color(1, 0, 0))  # Red for low FPS
	elif fps < 60:
		fps_label.add_theme_color_override("font_color", Color(1, 1, 0))  # Yellow for moderate FPS
	else:
		fps_label.add_theme_color_override("font_color", Color(0, 1, 0))  # Green for high FPS

	# Update the font size and position based on the window size
	_update_label()

# Update the label size and position based on window size
func _update_label():
	# Scale the font size according to the window width
	var font_size = int(get_viewport().size.x * 0.02)  # 2% of the screen width
	font_file.font_weight = font_size
	
	# Get the minimum size of the label (its width)
	var label_width = fps_label.get_minimum_size().x
	
	# Position the label at the top-right corner of the screen
	var viewport_size = get_viewport().size
	fps_label.position = Vector2(viewport_size.x - label_width - 175, 5)  # 10px margin from the top-right corner
