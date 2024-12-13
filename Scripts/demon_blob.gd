extends EnemyBase
class_name Blob
func _physics_process(delta):
	if !is_target_reachable && mapRID.is_valid():
		if navigation_agent.is_navigation_finished() && navigation_agent.is_target_reached():
			if player_target != null:
				if target_reachable(player_target.global_position):
					is_target_reachable = true
					return
			set_movement_target(await find_random_destination(75))
			return
	elif is_target_reachable && player_target != null:
		## Maybe add some tick/interval between setting movement target
		set_movement_target(player_target.global_position)
	var next_path_position: Vector2
	next_path_position = navigation_agent.get_next_path_position()
	velocity = global_position.direction_to(next_path_position) * movement_speed
	move_and_slide()

## ATTACKING FUNCTIONS
func _on_detection_area_2d_body_entered(body):
	if body.is_in_group("Player"):
		player_target = body
		is_target_reachable = target_reachable(player_target.global_position)
func _on_hit_area_2d_body_entered(body):
	if body == player_target:
		can_attack = true
		if attack_timer.is_stopped():
			player_target.change_health(-attack_damage, "Fire")
			attack_timer.start()
func _on_hit_area_2d_body_exited(body):
	if body == player_target:
		can_attack = false
func _on_attack_timer_timeout():
	if can_attack:
		player_target.change_health(-attack_damage, "Fire")
		attack_timer.start()
