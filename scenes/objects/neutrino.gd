class_name Neutrino extends Atom

func _ready() -> void:
	collision.shape.radius = radius
	element_name = "neutrino"
	sprite.material.set_shader_parameter("replace_colors", [data.color])
	
	animation.play("spawn")

func disappear() -> void:
	animation.play("disappear")
	
	await animation.animation_finished
	queue_free()
