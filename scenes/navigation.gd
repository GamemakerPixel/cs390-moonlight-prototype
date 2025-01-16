extends NavigationRegion3D


func _on_rooms_generation_done(_map_dimentions: Vector2i, _room_size: Vector2i) -> void:
	bake_navigation_mesh()
