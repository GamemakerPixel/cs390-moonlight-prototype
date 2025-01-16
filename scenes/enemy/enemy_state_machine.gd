extends StateMachine
class_name EnemyStateMachine

enum EnemyStates
{
	PATROL,
	CHASE,
	SEARCH_LAST,
}

var enemy: Enemy


func _ready() -> void:
	states = {
		EnemyStates.PATROL: $Patrol,
		EnemyStates.CHASE: $Chase,
		EnemyStates.SEARCH_LAST: $SearchLast,
	}
	process_mode = ProcessMode.PROCESS_MODE_DISABLED

@warning_ignore("shadowed_variable")
func start(enemy: Enemy) -> void:
	self.enemy = enemy
	initialize_state_resources()
	change_state_to(EnemyStates.PATROL)
	process_mode = ProcessMode.PROCESS_MODE_INHERIT


func initialize_state_resources() -> void:
	for state in get_children() as Array[EnemyState]:
		state.initialize_resources(self, enemy)


func _physics_process(delta: float) -> void:
	current_state.physics_process(delta)
