extends Control

func _on_resume_pressed():
	get_tree().paused = false
	hide()
	Util.mouse_captured()

func _on_settings_pressed():
	pass # Replace with function body.

func _on_exit_pressed():
	SceneChanger.change_scene("title_screen")
