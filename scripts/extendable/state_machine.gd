extends Node
class_name StateMachine

# state_identifier (Variant): state (State)
var states: Dictionary # Set before calling change_state_to
var current_state: State = null


func change_state_to(state_id) -> void:
	if not state_id in states:
		push_error("State " + str(state_id) + " doesn't exist!")
		return
	if current_state != null:
		current_state.exit()
	current_state = states[state_id]
	current_state.enter()
