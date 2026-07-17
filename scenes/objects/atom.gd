class_name Atom extends RigidBody2D

@onready var line2d: Line2D = $Line2D
@onready var springs_container: Node2D = $springs_container
@onready var collision: CollisionShape2D = $CollisionShape2D

@onready var label: Label = $Label

@export var element_name: String
@export var symbol: String
@export var index: int

@export var vertex_num: int = 16
@export var radius: float = 32.0
var springs = []

var atom_center: Vector2
var speed: float = 240.0
var color: Color = Color("#ffffff")

var shot: bool = false
var merging: bool = false
var colliding: bool = false

@export var data: ElementData

func _ready() -> void:
	element_name = data.element_name
	symbol = data.symbol
	index = data.index
	
	radius = data.radius
	color = data.color
	
	var c: Vector2 = position
	for i in range(vertex_num):
		var a: float = (2 * PI / vertex_num) * i
		var x: float = c.x + radius * cos(a)
		var y: float = c.y + radius * sin(a)

		var s: Spring = load(Registry.UID["spring"]).instantiate()
		springs_container.add_child(s)

		s.initialize(Vector2(x, y), i, c)
		springs.append(s)

	collision.shape.radius = radius
	label.label_settings.font_color = color
	label.text = symbol

func _process(_delta) -> void:
	var bodies: Array = get_colliding_bodies()
	if bodies.size() > 0:
		for entry in bodies:
			if entry is Atom:
				process_atom(entry)
	
	#var pts: Array = []
	#for s in springs:
		#pts.append(s.position)
	#if pts.size() > 0:
		#pts.append(pts[0])
	#line2d.points = pts
	
	if shot:
		var to_center: Vector2 = atom_center - global_position
		if to_center.length() > 6.0:
			var potential_velocity: Vector2 = to_center.normalized() * speed
			linear_velocity = potential_velocity if potential_velocity.length() > 0.1 else Vector2.ZERO
		else:
			linear_velocity = Vector2.ZERO
	else:
		global_position = get_parent().global_position
	

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
