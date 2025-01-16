extends Node


var default_mouse_mode := Input.MouseMode.MOUSE_MODE_VISIBLE :
	set = _set_default_mouse_mode


func _set_default_mouse_mode(mouse_mode: Input.MouseMode) -> void:
	default_mouse_mode = mouse_mode
	Input.mouse_mode = default_mouse_mode
