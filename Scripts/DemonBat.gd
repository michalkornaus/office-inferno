extends CharacterBody2D

var movement_speed: float = 50.0
var movement_target_position: Vector2
var target: CharacterBody2D

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
var mapRID: RID
var regionRID: RID

func _ready():
	navigation_agent.path_desired_distance = 4.0
	navigation_agent.target_desired_distance = 4.0
	actor_setup.call_deferred()

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
		if global_position.distance_to(random_point) <= distance:
			is_point_in_area = true
			break
	return random_point

func set_movement_target(movement_target: Vector2):
	navigation_agent.target_position = movement_target

func _physics_process(delta):
	if navigation_agent.is_navigation_finished() && target == null && navigation_agent.is_target_reached():
		print("Finding new destination point!")
		set_movement_target(await find_random_destination(75))
		return
		
	if target != null && movement_target_position != target.global_position:
		movement_target_position = target.global_position
		set_movement_target(movement_target_position)

	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()

	velocity = current_agent_position.direction_to(next_path_position) * movement_speed
	move_and_slide()

func _on_detection_area_2d_body_entered(body):
	if body.is_in_group("Player"):
		target = body
