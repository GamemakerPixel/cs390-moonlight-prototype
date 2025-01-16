extends CharacterBody3D

signal game_over

const MOUSE_SENSITIVITY = 0.005

const WALK_SPEED = 3.0
const SPRINT_SPEED = 5.5
const WEREWOLF_SPEED = 7.0

var move_velocity := Vector3.ZERO
var sprinting := false

var werewolf := false : set = _set_werewolf


func _ready() -> void:
	MouseControl.default_mouse_mode = Input.MouseMode.MOUSE_MODE_CAPTURED
	$WerewolfTimer.timeout.connect(
		func(): werewolf = false
	)


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


func _physics_process(_delta: float) -> void:
	velocity = move_velocity
	move_and_slide()


func become_werewolf() -> void:
	if not werewolf:
		$TransformSound.play()
	werewolf = true
	$WerewolfTimer.start()


func _recalculate_move_velocity(move_input: Vector2) -> void:
	var move_direction := basis.x * move_input.x - basis.z * move_input.y
	var move_speed := SPRINT_SPEED if sprinting else WALK_SPEED
	if werewolf:
		move_speed = WEREWOLF_SPEED
	
	move_velocity = move_direction * move_speed


func _rotate(local_position: Vector2) -> void:
	var rotation_difference := -local_position * MOUSE_SENSITIVITY
	rotate_y(rotation_difference.x)
	$Camera.rotate_x(rotation_difference.y)


func _on_enemy_collided(body: Node3D) -> void:
	if werewolf:
		body.on_destroyed()
	else:
		game_over.emit()
		$UI.game_over()


func _set_werewolf(new_werewolf: bool) -> void:
	werewolf = new_werewolf
	$UI.werewolf_overlay = werewolf
	
	var move_input := Input.get_vector(
			"move_left", "move_right", "move_backward", "move_forward"
		)
	_recalculate_move_velocity(move_input)
