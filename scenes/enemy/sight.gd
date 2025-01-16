extends Area3D
class_name SightArea3D

signal target_sighted(target: Node3D)
signal target_lost(last_seen_at: Vector3)

var target: Node3D = null
var target_in_sight: bool = false
var last_seen_at: Vector3 = Vector3.ZERO


func _physics_process(_delta: float) -> void:
	# Find a way to avoid busy waiting if this prototype is used.
	if target:
		var point_vector: Vector3 = (target.global_position - $Ray.global_position).rotated(Vector3.UP, -global_rotation.y)
		$Ray.target_position = point_vector
		if $Ray.is_colliding() and $Ray.get_collider() == target and not target_in_sight:
			target_sighted.emit(target)
			target_in_sight = true
		elif not $Ray.is_colliding() and target_in_sight:
			last_seen_at = target.position
			target_lost.emit(last_seen_at)
			target_in_sight = false


func get_last_seen_at() -> Vector3:
	return last_seen_at


func _on_target_entered_range(body: Node3D) -> void:
	target = body
	$Ray.enabled = true


func _on_target_exited_range(body: Node3D) -> void:
	if target_in_sight:
		last_seen_at = body.position
		target_lost.emit(last_seen_at)
	$Ray.enabled = false
	target_in_sight = false
	target = null
