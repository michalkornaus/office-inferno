extends CharacterBody2D
class_name Bat
## HEALTH VARIABLES
@export var enemy_health: int = 25
var current_health: int:
	get:
		return current_health
	set(value):
		current_health = value
		health_bar.set_value(current_health)
signal health_changed(amount, dmg_type)
@onready var health_bar: TextureProgressBar = $HealthBar
@export var info_label: PackedScene
## NAVIGATION VARIABLES
@export_category("Navigation variables")
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
var mapRID: RID
var regionRID: RID
@export var movement_speed: float = 50.0
## Distance in pixels in which enemy will search for new point on tilemap
@export var new_wavepoint_distance: float = 75
var movement_target_position: Vector2
var target: CharacterBody2D
var is_target_reachable: bool = false
## ATTACKING VARIABLES
@export_category("Attack variables")
@export var attack_damage: float = 5.0
@export var attack_cooldown: float = 1
@onready var attack_timer: Timer = $AttackTimer
var can_attack: bool = false

func _ready():
	# Setup health variables
	current_health = enemy_health
	health_bar.set_max(enemy_health)
	health_bar.set_value(current_health)
	# Setup navmesh variables
	navigation_agent.path_desired_distance = 4.0
	navigation_agent.target_desired_distance = 4.0
	attack_timer.wait_time = attack_cooldown
	actor_setup.call_deferred()


## NAVIGATION FUNCTIONS
func actor_setup():
	await get_tree().physics_frame
	mapRID = navigation_agent.get_navigation_map()
	regionRID = NavigationServer2D.map_get_regions(mapRID)[0] 
	set_movement_target(await find_random_destination(75))
func find_random_destination(distance: float):
	await get_tree().physics_frame
	var is_point_in_area: bool = false
	var random_point
	while is_point_in_area == false:	
		random_point = NavigationServer2D.region_get_random_point(regionRID, 1, false)
		if !target_reachable(random_point):
			continue
		if global_position.distance_to(random_point) <= distance:
			is_point_in_area = true
			break
	return random_point
func set_movement_target(movement_target: Vector2):
	navigation_agent.target_position = movement_target
func target_reachable(_target):
	var path = NavigationServer2D.map_get_path(mapRID, global_position, _target, true)
	return path[path.size() - 1].is_equal_approx(_target)
func _physics_process(delta):
	if !is_target_reachable:
		if navigation_agent.is_navigation_finished() && navigation_agent.is_target_reached():
			if target != null:
				if target_reachable(target.global_position):
					is_target_reachable = true
					return
			set_movement_target(await find_random_destination(75))
			return
	elif is_target_reachable && target != null:
		if movement_target_position != target.global_position:
			movement_target_position = target.global_position
			set_movement_target(movement_target_position)
	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()
	velocity = current_agent_position.direction_to(next_path_position) * movement_speed
	move_and_slide()


## ATTACKING FUNCTIONS
func _on_detection_area_2d_body_entered(body):
	if body.is_in_group("Player"):
		target = body
		is_target_reachable = target_reachable(target.global_position)
func _on_hit_area_2d_body_entered(body):
	if body == target:
		can_attack = true
		if attack_timer.is_stopped():
			target.change_health(-attack_damage, "Physical")
			attack_timer.start()
func _on_hit_area_2d_body_exited(body):
	if body == target:
		can_attack = false
func _on_attack_timer_timeout():
	if can_attack:
		target.change_health(-attack_damage, "Physical")
		attack_timer.start()

## HEALTH FUNCTIONS
func change_health(amount, dmg_type):
	self.current_health += amount
	if current_health <= 0:
		queue_free()
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
