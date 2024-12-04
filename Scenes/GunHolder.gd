extends Node2D
func _process(delta):
	look_at(get_global_mouse_position())
	set_rotation_degrees(snapped(rotation_degrees, 15))
