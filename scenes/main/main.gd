extends Node2D

@onready var atom_pivot: Node2D = $atom_pivot
@onready var atom_container: Node2D = $atom_pivot/atom_container
@onready var atoms: Node2D = $atoms

var radius: float = 200.0
var speed: float = 1.0
var angle: float = 0.0

enum ATOMS {
	neutrino,
	element
}
var next_atom_type: ATOMS = ATOMS.neutrino

func _ready() -> void:
	new_atom()

func _process(delta) -> void:
	angle += delta * speed
	atom_container.global_position = atom_pivot.global_position + Vector2(cos(angle), sin(angle)) * radius

	if not GameManager.game_running: return
	if Input.is_action_just_pressed("interact"):
		use_atom()

func use_atom() -> void:
	var current_atom: Atom = atom_container.get_child(0)
	if not current_atom: return

	current_atom.shot = true
	current_atom.reparent(atoms)
	current_atom.global_position = atom_container.global_position

	current_atom.set_collision_layer_value(1, true)
	current_atom.set_collision_mask_value(1, true)

	get_tree().create_timer(0.2).timeout.connect(new_atom)

func new_atom() -> void:
	var atom: Atom

	# choose a random atom or neutrino
	if next_atom_type == ATOMS.neutrino:
		atom = load(Registry.UID.neutrino).instantiate()
	else:
		atom = load(Registry.UID.atom).instantiate()

	atom.atom_center = atom_pivot.global_position
	atom_container.add_child(atom)
