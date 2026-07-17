extends Node2D

@onready var atom_pivot: Node2D = $atom_pivot
@onready var atom_container: Node2D = $atom_pivot/atom_container
@onready var atoms: Node2D = $atoms
@onready var line: Line2D = $atom_pivot/Line2D
@onready var key_sprite: Sprite2D = $key

@onready var next_atom_sprite: Sprite2D = $next_atom
@onready var next_atom_label: Label = $next_atom/next_atom_label

var radius: float = 240.0
var speed: float = 1.0
var angle: float = 0.0
var direction: int = 1

enum ATOMS {
	neutrino,
	element
}

var next_atom: Atom
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
	
	if atoms.get_children().size() >= 32:
		lose()
	
	if Input.is_action_pressed("interact"): 
		key_sprite.texture = load(Registry.UID["key_pressed"])
	else:
		key_sprite.texture = load(Registry.UID["key"])

func start() -> void:
	for i in range(GameManager.starting_atoms):
		var neutrino: Atom = load(Registry.UID.neutrino).instantiate()
		neutrino.global_position = Vector2(randf_range(0.5, 1.5), randf_range(0.5, 1.5))
		
		neutrino.set_collision_layer_value(1, true)
		neutrino.set_collision_mask_value(1, true)
		
		neutrino.atom_center = atom_pivot.global_position
		neutrino.shot = true
		
		atoms.add_child(neutrino)
	GameManager.game_running = true

func lose() -> void:
	pass

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
		if not next_atom: 
			atom = load(Registry.UID.atom).instantiate()
			
			var index: int = randi_range(0, GameManager.max_atom_index)
			atom.data = AtomManager.get_by_index(index)
		else:
			atom = next_atom
			next_atom = null
	
	atom.atom_center = atom_pivot.global_position
	atom_container.add_child(atom)
	
	next_atom = load(Registry.UID.atom).instantiate()
		
	var nindex: int = randi_range(0, GameManager.max_atom_index)
	next_atom.data = AtomManager.get_by_index(nindex)
	
	var _material: ShaderMaterial = ShaderMaterial.new()
	_material.shader = load(Registry.UID["color_swap"])
	
	_material.set_shader_parameter("target_colors", [Color("732f31")])
	_material.set_shader_parameter("replace_colors", [next_atom.data.color])
	_material.set_shader_parameter("tolerance", 0.03)
	_material.set_shader_parameter("color_count", 1)
	
	next_atom_sprite.material = _material
	next_atom_label.text = next_atom.data.symbol
	# next_atom_type = ATOMS.values().pick_random()
