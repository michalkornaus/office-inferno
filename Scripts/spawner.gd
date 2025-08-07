extends Node2D
@onready var timer: Timer = $Timer
@export var enemy_to_spawn: PackedScene
@export var time_to_spawn: float
@export var is_enemy_hostile: bool = false

func _ready():
	timer.wait_time = time_to_spawn
	timer.start()

func _on_timer_timeout():
	var new_enemy = enemy_to_spawn.instantiate()
	new_enemy.global_position = global_position
	if is_enemy_hostile:
		new_enemy.is_target_reachable = true
		new_enemy.player_target = get_tree().get_first_node_in_group("Player")
	get_node("/root/GameNode").add_child(new_enemy)
