extends Node3D

signal generation_done(map_dimentions: Vector2i, room_size: Vector2i)

const DOORWAY_TYPES = [
	Room.WallType.NO_WALL,
	Room.WallType.DOORWAY,
]

# (x, z)
const DIRECTIONS = [
	Vector2i(0, 1), # North
	Vector2i(1, 0), # East
	Vector2i(0, -1), # South
	Vector2i(-1, 0), # West
]

@export var room_scene: PackedScene
@export var room_size := Vector2i(8, 8) # (x, z)
@export var map_dimentions := Vector2i(8, 8) # (x, z) in rooms
@export_range(0.0, 1.0) var open_ceiling_probability: float = 0.25
@export_range(0.0, 1.0) var loop_probability: float = 0.1
@export_range(0.0, 1.0) var torch_probability: float = 0.15

# [x][z]
var _rooms: Array[Array] = []


func _ready() -> void:
	_create_rooms()
	_generate_maze()
	_create_loops()
	_place_torches()
	_place_rooms()
	generation_done.emit(map_dimentions, room_size)


func _create_rooms() -> void:
	for x in range(map_dimentions[0]):
		var row: Array = []
		for z in range(map_dimentions[1]):
			var room: Room = room_scene.instantiate()
			room.position = Vector3(
				x * room_size[0],
				0.0,
				z * room_size[1]
			)
			room.wall_types = [
				Room.WallType.WALL,
				Room.WallType.WALL,
				Room.WallType.WALL,
				Room.WallType.WALL,
			]
			row.append(room)
		_rooms.append(row)


func _generate_maze() -> void:
	# 0 = Not visited, 1 = added to stack, 2 = visited
	var room_status: Array[Array] = []
	for x in range(map_dimentions[0]):
		var row := []
		row.resize(map_dimentions[1])
		row.fill(0)
		room_status.append(row)
	# Storing the stack as a jagged 2d array (subarrays include rooms added by 
	# a single node each) enables randomly choosing from the top array on the
	# stack.
	var room_stack: Array[Array] = []
	room_stack.append([Vector2i(
		randi_range(0, map_dimentions[0] - 1),
		randi_range(0, map_dimentions[1] - 1),
	)])
	while room_stack.size() != 0:
		var options: Array = room_stack.back()
		var random_index: int = randi_range(0, options.size() - 1)
		var visiting_room_index: Vector2i = options.pop_at(random_index)
		var visiting_room: Room = _rooms[
			visiting_room_index[0]][visiting_room_index[1]
		]
		room_status[visiting_room_index[0]][visiting_room_index[1]] = 2
		if options.is_empty():
			room_stack.pop_back()
		
		var adj_room_indices := _get_adjacent(visiting_room_index)
		var discovered_rooms: Array[Vector2i] = []
		for adj_room_index in adj_room_indices:
			if room_status[adj_room_index[0]][adj_room_index[1]] != 0:
				continue
			
			room_status[adj_room_index[0]][adj_room_index[1]] = 1
			discovered_rooms.append(adj_room_index)
			var direction := adj_room_index - visiting_room_index
			var doorway: Room.WallType = DOORWAY_TYPES[randi_range(0, 1)]
			var ceiling: Room.CeilingType = Room.CeilingType.NORMAL
			if randf() < open_ceiling_probability:
				ceiling = Room.CeilingType.OPEN
			
			var adj_room: Room = _rooms[adj_room_index[0]][adj_room_index[1]]
			
			visiting_room.set_wall_type_by_direction(direction, doorway)
			adj_room.set_wall_type_by_direction(-direction, doorway)
			visiting_room.ceiling_type = ceiling
		
		if discovered_rooms:
			room_stack.append(discovered_rooms)


func _get_adjacent(room_index: Vector2i) -> Array[Vector2i]:
	var adjacent: Array[Vector2i] = []
	for x in range(
		max(0, room_index.x - 1),
		min(room_index.x + 1, map_dimentions[0] - 1) + 1
	):
		var adj_room_index = Vector2i(x, room_index.y)
		if adj_room_index == room_index:
			continue
		adjacent.append(adj_room_index)
	
	for z in range(
		max(0, room_index.y - 1),
		min(room_index.y + 1, map_dimentions[1] - 1) + 1
	):
		var adj_room_index = Vector2i(room_index.x, z)
		if adj_room_index == room_index:
			continue
		adjacent.append(adj_room_index)
	
	return adjacent


func _create_loops() -> void:
	# Accounting for the fact that the chance to change into an open wall is given
	# to both sizes of a wall.
	var real_loop_probability = 1 - sqrt(1 - loop_probability)
	
	for x in range(_rooms.size()):
		for z in range(_rooms[x].size()):
			var room: Room = _rooms[x][z]
			for wall_index in range(DIRECTIONS.size()):
				var wall_direction: Vector2i = DIRECTIONS[wall_index]
				var wall_type := room.wall_types[wall_index]
				
				if wall_type != Room.WallType.WALL:
					continue
				
				if not randf() < real_loop_probability:
					continue
				
				var adjacent_room_index: Vector2i = Vector2i(x, z) + wall_direction
				# Don't make a doorway out of the map!
				if not _is_within_bounds(adjacent_room_index):
					continue
				
				var adjacent_room: Room = _rooms[adjacent_room_index.x][adjacent_room_index.y]
				room.set_wall_type_by_direction(wall_direction, Room.WallType.DOORWAY)
				adjacent_room.set_wall_type_by_direction(-wall_direction, Room.WallType.DOORWAY)


func _is_within_bounds(room_index: Vector2i) -> bool:
	return (
		room_index.x >= 0 and room_index.y >= 0
		and room_index.x < map_dimentions[0]
		and room_index.y < map_dimentions[1]
	)


func _place_torches() -> void:
	for x in range(_rooms.size()):
		for z in range(_rooms[x].size()):
			var room: Room = _rooms[x][z]
			for wall_index in range(DIRECTIONS.size()):
				var wall_direction: Vector2i = DIRECTIONS[wall_index]
				var wall_type := room.wall_types[wall_index]
				
				if wall_type != Room.WallType.WALL:
					continue
				
				if not randf() < torch_probability:
					continue
				
				room.set_torch_by_direction(wall_direction, true)


func _place_rooms() -> void:
	for row in _rooms:
		for room in row:
			add_child(room)
