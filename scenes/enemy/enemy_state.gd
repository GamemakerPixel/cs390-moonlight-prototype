extends State
class_name EnemyState

var state_machine: EnemyStateMachine
var enemy: Enemy

@warning_ignore("shadowed_variable")
func initialize_resources(state_machine: EnemyStateMachine, enemy: Enemy) -> void:
	self.state_machine = state_machine
	self.enemy = enemy


func physics_process(_delta: float) -> void:
	pass
