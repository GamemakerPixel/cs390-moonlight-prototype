extends CharacterBody3D

const MOUSE_SENSITIVITY = 0.005

const WALK_SPEED = 3.0
const SPRINT_SPEED = 5.5

var move_velocity := Vector3.ZERO
var sprinting := false


func _ready() -> void:
	MouseControl.default_mouse_mode = Input.MouseMode.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_rotate(event.screen_relative)
	if event.is_action("move") or event.is_action("sprint") or event is InputEventMouseMotion:
		var move_input := Input.get_vector(
			"move_left", "move_right", "move_backward", "move_forward"
		)
		sprinting = Input.is_action_pressed("sprint")
		_recalculate_move_velocity(move_input)
	elif event.is_action_pressed("pause"):
		MouseControl.default_mouse_mode = Input.MouseMode.MOUSE_MODE_VISIBLE


func _process(delta: float) -> void:
	Input.get


func _physics_process(_delta: float) -> void:
	velocity = move_velocity
	move_and_slide()


func _recalculate_move_velocity(move_input: Vector2) -> void:
	var move_direction := basis.x * move_input.x - basis.z * move_input.y
	var move_speed := SPRINT_SPEED if sprinting else WALK_SPEED
	
	move_velocity = move_direction * move_speed


func _rotate(local_position: Vector2) -> void:
	var rotation_difference := -local_position * MOUSE_SENSITIVITY
	rotate_y(rotation_difference.x)
	$Camera.rotate_x(rotation_difference.y)
