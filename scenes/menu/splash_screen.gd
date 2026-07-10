extends Control

@onready var animation: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	animation.play("fade")
	await animation.animation_finished
	SceneChanger.change_scene("title_screen")
