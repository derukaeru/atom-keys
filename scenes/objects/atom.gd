class_name Atom extends RigidBody2D

@onready var line2d: Line2D = $Line2D
@onready var springs_container: Node2D = $springs_container
@onready var collision: CollisionShape2D = $CollisionShape2D

@export var element_name: String
@export var symbol: String
@export var index: int

@export var vertex_num: int = 16
@export var radius: float = 32.0
var springs = []

var speed: float = 270.0
var atom_center: Vector2
var shot: bool = false
var merging: bool = false
var colliding: bool = false
var has_collided: bool = false

func _ready() -> void:
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

func _process(_delta) -> void:
	#var pts: Array = []
	#for s in springs:
		#pts.append(s.position)
	#if pts.size() > 0:
		#pts.append(pts[0])
	#line2d.points = pts
	
	if shot:
		var to_center: Vector2 = atom_center - global_position
		if to_center.length() > 6.0:
			if has_collided:
				if not colliding: 
					linear_velocity = to_center.normalized() * speed
			else: linear_velocity = to_center.normalized() * speed
		else:
			linear_velocity = Vector2.ZERO
	else:
		global_position = get_parent().global_position

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	var contact_count: int = state.get_contact_count()
	if contact_count > 0:
		colliding = true
	else:
		colliding = false
	
	if not has_collided:
		has_collided = true

func _on_body_entered(body: Node2D) -> void:
	if merging: return
	if body is Atom:
		if body.index != index or body.element_name == "neutrino": return
		if body.shot and shot:
			if get_instance_id() < body.get_instance_id():
				merging = true
				body.merging = true
				body.queue_free()
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
	
	var container: Node2D = get_tree().get_first_node_in_group("atoms")
	if not container: return
	
	container.call_deferred_thread_group("add_child", atom)
