extends Area3D


func _on_player_entered(body: Node3D) -> void:
	body.become_werewolf()
