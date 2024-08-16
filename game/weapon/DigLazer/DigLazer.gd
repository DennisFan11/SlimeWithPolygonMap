extends Destruction



const R = 50.0
const PointSize = 10
func _point_init():
	var arr = []
	for i in range(PointSize):
		var angle = (2*PI) / PointSize * i
		arr.append(Vector2(cos(angle) * R, sin(angle) * R ))
	%Colli.polygon = arr

func _ready():
	_point_init()
		
func _get_global_polygon():
	var arr = []
	for i in %Colli.polygon:
		arr.append($Area2D.to_global(i))
	return arr

func _physics_process(delta):
	look_at(get_global_mouse_position())
	for i in range(%Ray.collision_result.size()):
		var point = $".".to_local(%Ray.get_collision_point(i))
		$Area2D.position = Vector2(1.0,0.0) * point.length()
		if Input.is_action_pressed("click"):
			destruct($Area2D.get_overlapping_bodies(), _get_global_polygon())
		elif Input.is_action_pressed("rclick"):
			construct($Area2D.get_overlapping_bodies(), _get_global_polygon())
