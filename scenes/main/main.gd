extends Node2D

@onready var atom_pivot: Node2D = $atom_pivot
@onready var atom_container: Node2D = $atom_pivot/atom_container
@onready var atoms: Node2D = $atoms
@onready var line: Line2D = $atom_pivot/Line2D

var radius: float = 240.0
var speed: float = 1.0
var angle: float = 0.0
var direction: int = 1

enum ATOMS {
	neutrino,
	element
}
var next_atom_type: ATOMS = ATOMS.element
var can_shoot: bool = true

func _ready() -> void:
	start()
	new_atom()

func _process(delta) -> void:
	angle += delta * speed * direction
	atom_container.global_position = atom_pivot.global_position + Vector2(cos(angle), sin(angle)) * radius

	if not GameManager.game_running: return
	if Input.is_action_just_pressed("interact"):
		use_atom()

func start() -> void:
	for i in range(GameManager.starting_atoms):
		var neutrino: Atom = load(Registry.UID.neutrino).instantiate()
		neutrino.global_position = Vector2(randf_range(0.5, 1.5), randf_range(0.5, 1.5))
		
		neutrino.set_collision_layer_value(1, true)
		neutrino.set_collision_mask_value(1, true)
		
		neutrino.atom_center = atom_pivot.global_position
		neutrino.shot = true
		
		atoms.add_child(neutrino)

func use_atom() -> void:
	if not can_shoot: return
	can_shoot = false
	
	var current_atom: Atom = atom_container.get_child(0)
	if not current_atom: return

	current_atom.shot = true
	current_atom.reparent(atoms)
	current_atom.global_position = atom_container.global_position

	current_atom.set_collision_layer_value(1, true)
	current_atom.set_collision_mask_value(1, true)
	
	# direction *= -1
	
	new_atom()
	get_tree().create_timer(0.6).timeout.connect(
		func() -> void: 
			can_shoot = true
	)

func new_atom() -> void:
	var atom: Atom

	# choose a random atom or neutrino
	if next_atom_type == ATOMS.neutrino:
		atom = load(Registry.UID.neutrino).instantiate()
	else:
		atom = load(Registry.UID.atom).instantiate()
		
		var index: int = randi_range(0, GameManager.max_atom_index)
		atom.data = AtomManager.get_by_index(index)

	atom.atom_center = atom_pivot.global_position
	atom_container.add_child(atom)
	
	# next_atom_type = ATOMS.values().pick_random()
