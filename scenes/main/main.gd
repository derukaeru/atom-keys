extends Node2D

@onready var atom_pivot: Node2D = $atom_pivot
@onready var atom_container: Node2D = $atom_pivot/atom_container

var radius: float = 64.0
var speed: float = 4.2

var angle: float = 0.0

func _process(delta) -> void:
	angle += delta
	atom_container.global_position = atom_pivot.global_position + Vector2(cos(angle), sin(angle))
	
	if not GameManager.game_running: return
	if Input.is_action_just_pressed("interact"):
		use_atom()

func use_atom() -> void:
	var current_atom: Atom = atom_container.get_child(0)
