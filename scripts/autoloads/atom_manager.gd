extends Node

var ATOMS: Array[ElementData] = []

func _ready() -> void:
	var dir = DirAccess.open("res://scripts/elements/")
	for file in dir.get_files():
		if file.ends_with(".tres"):
			var data: ElementData = load("res://scripts/elements/%s" % file)
			ATOMS.append(data)
	
	ATOMS.sort_custom(func(a, b): return a.index < b.index)

func get_by_index(index: int) -> ElementData:
	if index < ATOMS.size():
		return ATOMS[index]
	return null
