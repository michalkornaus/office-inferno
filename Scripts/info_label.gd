extends Label
var wait_time: float = 0.5
func _ready():
	$Timer.start(wait_time)
func _process(delta):
	position.y -= delta * 10
func _on_timer_timeout():
	queue_free()
