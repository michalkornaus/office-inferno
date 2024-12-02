extends CharacterBody2D

@export var speed = 100
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed
	
func rotate_player():
	var rad_rot = position.angle_to_point(get_global_mouse_position())
	
	var deg_rot = rad_to_deg(rad_rot)
	var dir_string: String
	if deg_rot > 45 && deg_rot <= 135:
		dir_string = "front"
	elif deg_rot > -45 && deg_rot <= 45:
		dir_string = "right"
	elif deg_rot > 135 || deg_rot <= -135:
		dir_string = "left"
	elif deg_rot > -135 && deg_rot <= -45:
		dir_string = "back"
	if velocity.length() > 0:
		animated_sprite.animation = "run_" + dir_string
	else:
		animated_sprite.animation = "idle_" + dir_string

func _physics_process(delta):
	get_input()
	rotate_player()
	move_and_slide()
