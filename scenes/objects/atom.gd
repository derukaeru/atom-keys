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

var speed: float = 230.0
var atom_center: Vector2
var shot: bool = false

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
	var pts: Array = []
	for s in springs:
		pts.append(s.position)
	if pts.size() > 0:
		pts.append(pts[0])
	line2d.points = pts

	if shot:
		var to_center: Vector2 = atom_center - global_position
		if to_center.length() > 6.0:
			linear_velocity = to_center.normalized() * speed
		else:
			linear_velocity = Vector2.ZERO
	else:
		global_position = get_parent().global_position

func _on_body_entered(body: Node2D) -> void:
	if body is Atom:
		if body.index != index or body.element_name == "neutrino": return
		if body.shot and shot:
			body.queue_free()
