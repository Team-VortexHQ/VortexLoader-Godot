extends Node

@onready var mainScene = preload("res://scenes/Main.tscn").instantiate()
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_settings_pressed():
	get_tree().root.add_child(mainScene)
	pass # Replace with function body.
