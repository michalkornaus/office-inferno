extends Camera2D
@export var player: CharacterBody2D
func _physics_process(delta):
	global_position = lerp(global_position, player.global_position, 10 * delta)
