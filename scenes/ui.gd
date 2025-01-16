extends CanvasLayer

var werewolf_overlay := false : set = _set_werewolf_overlay


func _ready() -> void:
	$GameOver.hide()
	$WerewolfOverlay.hide()


func game_over() -> void:
	$GameOver.show()
	MouseControl.default_mouse_mode = Input.MouseMode.MOUSE_MODE_VISIBLE


func _set_werewolf_overlay(enabled: bool) -> void:
	werewolf_overlay = enabled
	$WerewolfOverlay.visible = werewolf_overlay
