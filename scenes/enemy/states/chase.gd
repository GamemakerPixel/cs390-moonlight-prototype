extends EnemyState


func enter() -> void:
	enemy.sight.target_lost.connect(_on_target_lost)


func physics_process(_delta: float) -> void:
	enemy.target_sighted_target()
	enemy.pursue_target(Enemy.CHASE_SPEED)


func _on_target_lost(last_seen: Vector3) -> void:
	enemy.target = null
	enemy.target_last_seen = last_seen
	state_machine.change_state_to(EnemyStateMachine.EnemyStates.SEARCH_LAST)


func exit() -> void:
	enemy.sight.target_lost.disconnect(_on_target_lost)
