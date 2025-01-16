extends EnemyState


func enter() -> void:
	enemy.navigation.target_reached.connect(_on_room_explored)
	enemy.sight.target_sighted.connect(_target_sighted)
	enemy.call_deferred("target_room_for_exploration")


func physics_process(_delta: float) -> void:
	enemy.pursue_target(Enemy.PATROL_SPEED)


func exit() -> void:
	enemy.navigation.target_reached.disconnect(_on_room_explored)
	enemy.sight.target_sighted.disconnect(_target_sighted)


func _on_room_explored() -> void:
	enemy.mark_queued_room_as_explored()
	enemy.call_deferred("target_room_for_exploration")


func _target_sighted(target: Node3D) -> void:
	enemy.target = target
	state_machine.change_state_to(EnemyStateMachine.EnemyStates.CHASE)
