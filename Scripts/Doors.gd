extends Node2D
@onready var anim_player: AnimationPlayer = $AnimationPlayer
var is_open: bool = false

func open_doors():
	$StaticBody2D.queue_free()
	anim_player.play("Open")
	is_open = true
	
func rebake_navmesh():
	get_tree().get_first_node_in_group("NavRegion").bake_navigation_polygon(true)
	
func _on_area_2d_body_entered(body):
	if body.is_in_group("Player") && !is_open:
		open_doors()

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Open":
		rebake_navmesh()
