extends "res://Scripts/PlayerMovement.gd"
class_name Player

@export var player_health: int = 100
var current_health: int:
	get:
		return current_health
	set(value):
		current_health = value
		health_bar.set_value(current_health)
signal health_changed(amount, dmg_type)
@onready var health_bar: TextureProgressBar = $HealthBar

@export_category("Reference scenes")
@export var info_label: PackedScene
@export var bullet_scene: PackedScene

@onready var gun_muzzle: Node2D = $GunHolder/GunSprite2D/GunMuzzle
@onready var attack_timer: Timer = $AttackTimer
signal shoot_bullet()
var can_shoot: bool = false

func _ready():
	current_health = player_health
	health_bar.set_max(player_health)
	health_bar.set_value(current_health)
	
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				emit_signal("shoot_bullet")
			elif event.is_released():
				can_shoot = false
	
func spawn_projectile():
	var new_bullet = bullet_scene.instantiate()
	new_bullet.position = gun_muzzle.global_position
	new_bullet.look_at(get_global_mouse_position())
	new_bullet.velocity = gun_muzzle.global_position.direction_to(get_global_mouse_position())
	get_parent().add_child(new_bullet)
	
func _on_shoot_bullet():
	can_shoot = true
	if attack_timer.is_stopped():
		spawn_projectile()
		attack_timer.start()
	
func _on_attack_timer_timeout():
	if can_shoot:
		spawn_projectile()
		attack_timer.start()

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
