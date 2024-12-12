extends Object
## Unused code for drawing rays - maybe helpful for later
#var can_draw: bool = false
#var result_pos: Vector2 
#func check_collision():
	#var end_pos = global_position + global_position.direction_to(get_global_mouse_position()) * 1000
	#var query = PhysicsRayQueryParameters2D.create(global_position, end_pos)
	#query.collide_with_bodies = true
	#query.exclude = [self]
	#var result = get_world_2d().direct_space_state.intersect_ray(query)
	#print(result)
	#if result:
		#if result.collider.is_in_group("Enemy"):
			#result.collider.change_health(-5, "Fire")
		#result_pos = result.position
		#can_draw = true
		#queue_redraw()
		#
#func _draw():
	#if can_draw:
		#draw_line(to_local(global_position), to_local(result_pos), Color.RED, 16, false)
		#can_draw = false

## Code for bouncing bullets
#var max_collisions: int = 1000
#var collisions_count: int = 0
#var slide = move_and_slide()
	#while (slide and collisions_count < max_collisions):
		#var collision = get_last_slide_collision()
		#var collider = collision.get_collider()
		#if collider is Bat:
			#collider.change_health(-5, "Fire")	
			#queue_free()
			#break
		#else:
			#var normal = collision.get_normal()
			#var remainder = collision.get_remainder()
			#velocity = velocity.bounce(normal)
			#remainder = remainder.bounce(normal)
			#collisions_count += 1
			#slide = move_and_slide()
	#if collisions_count >= max_collisions:
		#queue_free()
