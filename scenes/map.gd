extends Node3D

var map_dimentions: Vector2i
var room_size: Vector2i

@warning_ignore("shadowed_variable")
func _on_rooms_generation_done(map_dimentions: Vector2i, room_size: Vector2i) -> void:
	self.map_dimentions = map_dimentions
	self.room_size = room_size


# You may ask, why not just signal Enemies? Well, the navigation and rooms _ready will be called first,
# meaning the enemies in the scene cannot yet access their state machines. If Enemies were initialized
# first however, this would still be an issue because navigation needs to be ready when enemies need
# to pathfind.
func _ready() -> void:
	$Navigation.bake_finished.connect(
		func():
			$Enemies.spawn_enemies(map_dimentions, room_size)
			$Enemies.start_enemies(map_dimentions, room_size)
	)


func _on_game_over() -> void:
	process_mode = ProcessMode.PROCESS_MODE_DISABLED
