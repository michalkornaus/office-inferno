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
#extends CharacterBody2D
#class_name Bullet
#
#@export var damage := 10.0
#@export var initial_velocity := Vector2(50, 50)
#@export var max_collisions := 6
#
#var collision_count := 0
#
#func _ready():
	#velocity = initial_velocity
#
#func _physics_process(delta):
	#collision_count = 0
	#var collision = move_and_collide(velocity * delta)
	#
	#while (collision and collision_count < max_collisions):
		#var collider = collision.get_collider()
		#
		#if collider is Player:
			#collider.hit(damage)
			#queue.free()
			#break
		#else:
			#var normal = collision.get_normal()
			#var remainder = collision.get_remainder()
			#velocity = velocity.bounce(normal)
			#remainder = remainder.bounce(normal)
			#
			#collision_count += 1
			#collision = move_and_collide(remainder)
