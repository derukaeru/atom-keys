extends Node

@onready var pause_screen = load(Registry.UID["pause_screen"]).instantiate()

var canvas_layer = CanvasLayer.new()
var game_running: bool = true

var starting_atoms: int = 3
var max_atom_index: int = 4

func _ready() -> void:
	add_child(canvas_layer)
	canvas_layer.layer = 5
	canvas_layer.add_child(pause_screen)
	
	pause_screen.hide()
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(_d) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if get_tree().paused:
			get_tree().paused = false
			pause_screen.hide()
			Util.mouse_captured()
		else:
			get_tree().paused = true
			pause_screen.show()
			Util.mouse_visible()
