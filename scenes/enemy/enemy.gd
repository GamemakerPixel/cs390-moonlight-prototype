extends CharacterBody3D
class_name Enemy

const PATROL_SPEED = 2.0
const CHASE_SPEED = 3.5
const RUN_SPEED = 3.5

@onready var state_machine: EnemyStateMachine = $States
@onready var navigation: NavigationAgent3D = $NavigationAgent
@onready var sight: SightArea3D = $Sight

var map_dimentions: Vector2i
var room_size: Vector2i
var room_exploration_queue: Array[Vector2i]
var current_room_index := 0

var target: Node3D = null
var target_last_seen := Vector3.ZERO

@warning_ignore("shadowed_variable")
func begin(map_dimentions: Vector2i, room_size: Vector2i) -> void:
	self.map_dimentions = map_dimentions
	self.room_size = room_size
	_refresh_room_exploration_queue()
	state_machine.start(self)


func pursue_target(speed: float) -> void:
	var path_position: Vector3 = navigation.get_next_path_position()
	var direction := (path_position - position).normalized()
	if direction == Vector3.ZERO:
		return
	look_at(path_position)
	velocity = direction * speed
	move_and_slide()


func mark_queued_room_as_explored() -> void:
	current_room_index += 1
	if current_room_index == room_exploration_queue.size():
		current_room_index = 0


func target_room_for_exploration() -> void:
	var target_room := room_exploration_queue[current_room_index]
	var target_position := target_room * room_size
	navigation.target_position = Vector3(
		target_position.x,
		0.0,
		target_position.y
	)


func target_sighted_target() -> void:
	navigation.target_position = target.global_position


func target_last_seen_position() -> void:
	navigation.target_position = target_last_seen


func on_destroyed() -> void:
	$Animation.play("destroyed")


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		navigation.target_position = Vector3.ZERO
	elif event.is_action_released("ui_accept"):
		navigation.target_position = Vector3.ZERO 


func _refresh_room_exploration_queue() -> void:
	var possibilities: Array[Vector2i] = []
	for x in range(map_dimentions.x):
		for z in range(map_dimentions.y):
			possibilities.append(Vector2i(x, z))
	
	room_exploration_queue = []
	while (not possibilities.is_empty()):
		var random_index := randi_range(0, possibilities.size() - 1)
		room_exploration_queue.append(possibilities.pop_at(random_index))


func _on_animation_finished(anim_name: StringName) -> void:
	queue_free()
