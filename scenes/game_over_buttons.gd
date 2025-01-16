extends Control


func _on_try_again() -> void:
	get_tree().reload_current_scene()


func _on_quit() -> void:
	get_tree().quit()
