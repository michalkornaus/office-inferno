extends CharacterBody2D
@export var speed: float = 400
func _ready():
	velocity *= speed

func _physics_process(delta):
	var slide = move_and_slide()
	if slide: #if slide == true, collision occurred -> destroy bullet
		var collision = get_last_slide_collision()
		var collider = collision.get_collider()
		if !collider.is_in_group("Enemy"):
			queue_free()
		else:
			collider.change_health(-5, "Fire")	
			queue_free()
		
