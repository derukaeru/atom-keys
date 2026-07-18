extends Node

@export var ATOMS: Array[ElementData] = []

var atoms_dict: Node2D = load(Registry.UID["atoms_data_dictionary"]).instantiate()

func _ready() -> void:
	add_child(atoms_dict)
	
	ATOMS = atoms_dict.ATOMS
	ATOMS.sort_custom(func(a, b): return a.index < b.index)

func get_by_index(index: int) -> ElementData:
	if index < ATOMS.size():
		return ATOMS[index]
	return null
