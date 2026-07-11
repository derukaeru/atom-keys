class_name Atom extends Node2D

@onready var line2d: Line2D = $Line2D
@onready var springs_container: Node2D = $springs_container

@export var element_name: String
@export var symbol: String 

@export var index: int

@export var num: int = 16
@export var r: float = 32.0
@export var kc: float = 0.1
@export var dm: float = 0.05
var springs = []

func _ready() -> void:
	var c = position
	for i in range(num):
		var a = (2 * PI / num) * i
		var x = c.x + r * cos(a)
		var y = c.y + r * sin(a)
		
		var s = load(Registry.UID["spring"]).instantiate()
		springs_container.add_child(s)
		
		s.initialize(Vector2(x, y), i, c)
		springs.append(s)

func _process(_delta):
	var pts = []
	for s in springs:
		pts.append(s.position)
		
	if pts.size() > 0:
		pts.append(pts[0]) 
		
	line2d.points = pts
