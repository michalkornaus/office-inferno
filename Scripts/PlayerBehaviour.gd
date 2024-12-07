extends "res://Scripts/PlayerMovement.gd"

@export var player_health: int = 100
var current_health: int:
	get:
		return current_health
	set(value):
		current_health = value
		health_bar.set_value(current_health)
signal health_changed(amount, dmg_type)

@onready var health_bar: TextureProgressBar = $HealthBar
@export var info_label: PackedScene

func _ready():
	current_health = player_health
	health_bar.set_max(player_health)
	health_bar.set_value(current_health)
	
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			check_collision()
			
var can_draw: bool = false
var result_pos: Vector2 
func check_collision():
	var end_pos = global_position + global_position.direction_to(get_global_mouse_position()) * 1000
	var query = PhysicsRayQueryParameters2D.create(global_position, end_pos)
	query.collide_with_bodies = true
	query.exclude = [self]
	var result = get_world_2d().direct_space_state.intersect_ray(query)
	print(result)
	if result:
		if result.collider.is_in_group("Enemy"):
			result.collider.change_health(-5, "Fire")
		result_pos = result.position
		can_draw = true
		queue_redraw()
		
func _draw():
	if can_draw:
		draw_line(to_local(global_position), to_local(result_pos), Color.RED, 16, false)
		can_draw = false

func change_health(amount, dmg_type):
	self.current_health += amount
	if current_health <= 0:
		pass
	emit_signal("health_changed", amount, dmg_type)

func _on_health_changed(amount, dmg_type):
	if amount == 0:
		return
	var new_label = info_label.instantiate()
	new_label.position = Vector2(randi_range(-12, -20), randi_range(-27, -33))
	new_label.wait_time = 0.5 + (0.01 * abs(amount))
	if amount > 0:
		new_label.modulate = Color.GREEN
		new_label.text = "+" + str(amount)
	elif amount < 0:
		var color: Color
		match dmg_type:
			"Physical": color = Color.RED
			"Fire": color = Color.ORANGE_RED
			"Acid": color = Color.DARK_GREEN
			"Bleed": color = Color.DARK_RED
			"Curse": color = Color.BLUE_VIOLET
			"Magic": color = Color.DARK_VIOLET
			"Ice": color = Color.DEEP_SKY_BLUE
		new_label.modulate = color
		new_label.text = "-" + str(abs(amount))
	add_child(new_label)
