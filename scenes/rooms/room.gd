@tool
class_name Room
extends Node3D

enum WallType {
	NO_WALL,
	WALL,
	DOORWAY,
}

enum CeilingType {
	NORMAL,
	OPEN,
}

const WALL_SCENES = {
	WallType.NO_WALL: preload("res://scenes/rooms/architecture/no_wall.tscn"),
	WallType.WALL: preload("res://scenes/rooms/architecture/wall.tscn"),
	WallType.DOORWAY: preload("res://scenes/rooms/architecture/doorway.tscn"),
}

const CEILING_SCENES = {
	CeilingType.NORMAL: preload("res://scenes/rooms/architecture/ceiling.tscn"),
	CeilingType.OPEN: preload("res://scenes/rooms/architecture/open_ceiling.tscn"),
}

const TORCH_SCENE = preload("res://scenes/rooms/lighting/torch.tscn")

const WALL_DIRECTIONS := {
	Vector2i(0, 1): 0,
	Vector2i(1, 0): 1,
	Vector2i(0, -1): 2,
	Vector2i(-1, 0): 3,
}

@onready var walls := [
	$Walls/North,
	$Walls/East,
	$Walls/South,
	$Walls/West,
]

@onready var ceiling := $BaseMeshes/Ceiling

@onready var torch_positions := [
	$Torches/North,
	$Torches/East,
	$Torches/South,
	$Torches/West,
]

# North, East, South, West
@export var wall_types: Array[WallType] = [
	WallType.NO_WALL,
	WallType.NO_WALL,
	WallType.NO_WALL,
	WallType.NO_WALL,
] : set = _set_wall_types

@export var ceiling_type: CeilingType = CeilingType.NORMAL : set = _set_ceiling_type

@export var torches: Array[bool] = [
	false,
	false,
	false,
	false,
] : set = _set_torches


func _ready() -> void:
	_update_walls()
	_update_ceiling()
	_update_torches()


func set_wall_type_by_direction(direction: Vector2i, type: WallType) -> void:
	if direction not in WALL_DIRECTIONS:
		push_error("There is no wall in direction {}".format(direction))
		return
	
	wall_types[WALL_DIRECTIONS[direction]] = type


func set_torch_by_direction(direction: Vector2i, place_torch: bool) -> void:
	if direction not in WALL_DIRECTIONS:
		push_error("There is no wall in direction {}".format(direction))
		return
	
	torches[WALL_DIRECTIONS[direction]] = place_torch


func _set_wall_types(new_wall_types: Array[WallType]) -> void:
	wall_types = new_wall_types
	_update_walls()


func _set_ceiling_type(new_ceiling_type: CeilingType) -> void:
	ceiling_type = new_ceiling_type
	_update_ceiling()


func _set_torches(new_torches: Array[bool]) -> void:
	torches = new_torches
	_update_torches()


func _update_walls() -> void:
	for wall_index in range(walls.size()):
		var wall_parent: Node3D = walls[wall_index]
		for child in wall_parent.get_children():
			child.queue_free()
		var wall_type: WallType = wall_types[wall_index]
		var wall_scene: PackedScene = WALL_SCENES[wall_type]
		var wall: Node3D = wall_scene.instantiate()
		wall_parent.add_child(wall)


func _update_ceiling() -> void:
	if not ceiling:
		return
	for child in ceiling.get_children():
		child.queue_free()
	
	var ceiling_scene: PackedScene = CEILING_SCENES[ceiling_type]
	var ceiling_node: Node3D = ceiling_scene.instantiate()
	ceiling.add_child(ceiling_node)


func _update_torches() -> void:
	for torch_index in range(torch_positions.size()):
		var torch_position: Node3D = torch_positions[torch_index]
		for child in torch_position.get_children():
			child.queue_free()
		
		if not torches[torch_index]:
			continue
		
		var torch: Node3D = TORCH_SCENE.instantiate()
		torch_position.add_child(torch)
