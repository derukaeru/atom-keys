class_name Atom extends RigidBody2D

@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D

@onready var label: Label = $Label

@export var element_name: String
@export var symbol: String
@export var index: int

@export var radius: float = 32.0
@export var data: ElementData

var atom_center: Vector2
var speed: float = 220.0

var color: Color = Color("#ffffff")
var target_color: Color = Color("732f31")

var shot: bool = false
var merging: bool = false
var colliding: bool = false

var explosion_force: float = 900.0

func _ready() -> void:
	element_name = data.element_name
	symbol = data.symbol
	index = data.index
	
	radius = data.radius
	color = data.color

	collision.shape.radius = radius
	label.text = symbol
	
	var _material: ShaderMaterial = ShaderMaterial.new()
	_material.shader = load(Registry.UID["color_swap"])
	
	_material.set_shader_parameter("target_colors", [target_color])
	_material.set_shader_parameter("replace_colors", [color])
	_material.set_shader_parameter("tolerance", 0.03)
	_material.set_shader_parameter("color_count", 1)
	
	sprite.material = _material

func _process(_delta) -> void:
	var bodies: Array = get_colliding_bodies()
	if bodies.size() > 0:
		for entry in bodies:
			if entry is Atom:
				process_atom(entry)
	
	if shot:
		var to_center: Vector2 = atom_center - global_position
		if to_center.length() > 6.0:
			var potential_velocity: Vector2 = to_center.normalized() * speed
			linear_velocity = potential_velocity if potential_velocity.length() > 0.1 else Vector2.ZERO
		else:
			linear_velocity = Vector2.ZERO
	else:
		global_position = get_parent().global_position
	
	label.rotation = -rotation

func _on_body_entered(body: Node2D) -> void:
	if merging: return
	if body is Atom:
		process_atom(body)

func process_atom(atom: Atom):
	if not atom.shot or not shot: return

	if atom.index != index or atom.element_name == "neutrino": return
	if get_instance_id() < atom.get_instance_id():
		merging = true
		atom.merging = true
		atom.queue_free()
		
		spawn_new_atom()
		explode()
		queue_free()
		
		return

func spawn_new_atom() -> void:
	var atom: Atom = load(Registry.UID.atom).instantiate()
	atom.index = index + 1
	atom.shot = true
	
	atom.position = position
	atom.atom_center = atom_center
	
	atom.set_collision_layer_value(1, true)
	atom.set_collision_mask_value(1, true)
	
	atom.data = AtomManager.get_by_index(atom.index)
	
	if atom.index > GameManager.max_atom_index:
		GameManager.max_atom_index += 1
	
	var container: Node2D = get_tree().get_first_node_in_group("atoms")
	if not container: return
	
	container.call_deferred_thread_group("add_child", atom)

func explode() -> void:
	for body in get_colliding_bodies():
		if body is Atom:
			
			var dir: Vector2 = body.global_position - global_position
			body.apply_central_impulse(dir.normalized() * explosion_force)
