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
@onready var info_label: Label = $InfoLabel

func _ready():
	current_health = player_health
	health_bar.set_max(player_health)
	health_bar.set_value(current_health)

func change_health(amount, dmg_type):
	self.current_health += amount
	if current_health <= 0:
		print("dede")
	emit_signal("health_changed", amount, dmg_type)

func _on_health_changed(amount, dmg_type):
	if amount == 0:
		return
	info_label.text = str(amount)
	await get_tree().create_timer(0.5).timeout
	info_label.text = ""
