extends Node3D

const ENEMY_SCENE = preload("res://scenes/enemy/enemy.tscn")

@export var minimum_distance_from_player: float = 25.0
@export_range(0.0, 1.0) var spawn_probability: float = 0.075


func spawn_enemies(map_dimentions: Vector2i, room_size: Vector2i) -> void:
	for x in range(map_dimentions.x):
		for z in range(map_dimentions.y):
			var spawn_position: Vector3 = Vector3(
				x * room_size.x,
				0.0,
				z * room_size.y
			)
			if not _can_spawn_at(spawn_position):
				continue
			if not randf() < spawn_probability:
				continue
			var enemy = ENEMY_SCENE.instantiate()
			enemy.position = spawn_position
			add_child(enemy)


func start_enemies(map_dimentions: Vector2i, room_size: Vector2i) -> void:
	for enemy in get_children() as Array[Enemy]:
		enemy.begin(map_dimentions, room_size)


func _can_spawn_at(spawn_position: Vector3) -> bool:
	# When the player isn't guarenteed to spawn at <0, 0, 0>, this needs to be
	# changed.
	return spawn_position.length() >= minimum_distance_from_player
