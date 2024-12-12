extends CharacterBody2D
class_name EnemyBase
## HEALTH VARIABLES
@export_category("Health variables")
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
@export var target_detection_range: float = 150
var movement_target_position: Vector2
var player_target: CharacterBody2D
var is_target_reachable: bool = false

## ATTACKING VARIABLES
@export_category("Attack variables")
@export var attack_damage: float = 5.0
@export var attack_cooldown: float = 1
@onready var attack_timer: Timer = $AttackTimer
@export var attack_range: float = 15.0
var can_attack: bool = false

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	# Setup health variables
	current_health = enemy_health
	health_bar.set_max(enemy_health)
	health_bar.set_value(current_health)
	# Setup areas 2D ranges
	$HitArea2D/CollisionShape2D.shape.radius = attack_range
	$DetectionArea2D/CollisionShape2D.shape.radius = target_detection_range
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
	if !mapRID.is_valid():
		return false
	var path = NavigationServer2D.map_get_path(mapRID, global_position, _target, true)
	return path[path.size() - 1].is_equal_approx(_target)
	
func _process(delta):
	if velocity.x < 0:
		anim_sprite.flip_h = true
	else:
		anim_sprite.flip_h = false

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
