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
#@onready var info_label: Label = $InfoLabel
@export var info_label: PackedScene

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
