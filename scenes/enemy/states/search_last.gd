extends EnemyState


func enter() -> void:
	enemy.sight.target_sighted.connect(_on_target_sighted)
	enemy.navigation.target_reached.connect(_on_last_position_reached)


func physics_process(_delta: float) -> void:
	enemy.target_last_seen_position()
	enemy.pursue_target(Enemy.CHASE_SPEED)


func _on_target_sighted(target: Node3D) -> void:
	enemy.target = target
	state_machine.change_state_to(EnemyStateMachine.EnemyStates.CHASE)


func _on_last_position_reached() -> void:
	state_machine.change_state_to(EnemyStateMachine.EnemyStates.PATROL)


func exit() -> void:
	enemy.sight.target_sighted.disconnect(_on_target_sighted)
	enemy.navigation.target_reached.disconnect(_on_last_position_reached)
