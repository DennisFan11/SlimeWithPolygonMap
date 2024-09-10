extends CharacterBody2D


const SPEED = 300.0

var time:float = 0.0
func _physics_process(delta):
	time += delta
	if time >= 0.3:
		time = 0.0
		_set_target(Global.PlayerPosition)
	var pos = $NavigationAgent2D.get_next_path_position()
	velocity = (pos - global_position).normalized() * SPEED
	move_and_slide()
	$Polygon2D.look_at(pos)
func _set_target(pos):
	$NavigationAgent2D.target_position = pos
	#$NavigationAgent2D.set_velocity_forced(SPEED)
