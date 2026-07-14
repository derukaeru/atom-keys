class_name Neutrino extends Atom

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
	element_name = "neutrino"
