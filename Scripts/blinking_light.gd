extends PointLight2D
func _ready():
	blink_light()
func blink_light():
	await get_tree().create_timer(randf_range(0.5, 3)).timeout 
	enabled = !enabled
	await get_tree().create_timer(randf_range(0.1, 0.2)).timeout 
	enabled = !enabled
	blink_light()
