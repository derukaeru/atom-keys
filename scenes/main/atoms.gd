extends Node2D

func _process(_delta) -> void:
	queue_redraw()

func _draw() -> void:
	var drawn_pairs := {}
	for atom in get_children():
		if atom is Atom:
			draw_line(atom.position, Vector2.ZERO, Color(0.224, 0.224, 0.224, 0.541), 3.0)
			
			for neighbor in get_closest(atom, 1):
				var key = _pair_key(atom, neighbor)
				if drawn_pairs.has(key):
					continue
				drawn_pairs[key] = true
			
				draw_line(atom.position, neighbor.position, Color(0.224, 0.224, 0.224, 0.541), 3.0)

func get_closest(atom: Atom, count: int) -> Array:
	var others = get_children().duplicate()
	others.erase(atom)
	others.sort_custom(func(a, b):
		return atom.global_position.distance_squared_to(a.global_position) \
			< atom.global_position.distance_squared_to(b.global_position)
	)
	return others.slice(0, count)

func _pair_key(a: Atom, b: Atom) -> String:
	var ia = a.get_instance_id()
	var ib = b.get_instance_id()
	
	return str(min(ia, ib)) + "_" + str(max(ia, ib))
