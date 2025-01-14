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

# North, East, South, West
@export var wall_types: Array[WallType] = [
	WallType.NO_WALL,
	WallType.NO_WALL,
	WallType.NO_WALL,
	WallType.NO_WALL,
] : set = _set_wall_types


@export var ceiling_type: CeilingType = CeilingType.NORMAL : set = _set_ceiling_type


func _ready() -> void:
	_update_walls()
	_update_ceiling()


func set_wall_type_by_direction(direction: Vector2i, type: WallType) -> void:
	if direction not in WALL_DIRECTIONS:
		push_error("There is no wall in direction {}".format(direction))
		return
	
	wall_types[WALL_DIRECTIONS[direction]] = type


func _set_wall_types(new_wall_types: Array[WallType]) -> void:
	wall_types = new_wall_types
	_update_walls()


func _set_ceiling_type(new_ceiling_type: CeilingType) -> void:
	ceiling_type = new_ceiling_type
	_update_ceiling()


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
