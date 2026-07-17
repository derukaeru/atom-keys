class_name Neutrino extends Atom

func _ready() -> void:
	collision.shape.radius = radius
	element_name = "neutrino"
	sprite.material.set_shader_parameter("replace_colors", [data.color])
