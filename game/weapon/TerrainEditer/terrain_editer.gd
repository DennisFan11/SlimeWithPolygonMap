extends Destruction

const R = 20.0 #70
const POINT_SIZE = 20 #20
func _polygon_init():
	var arr = []
	for i in range(POINT_SIZE):
		var angle = PI*2 / POINT_SIZE * i
		arr.append(Vector2(cos(angle) * R, sin(angle) * R))
	%Colli.polygon = arr


func _ready():
	_polygon_init()

func _physics_process(delta):
	global_position = get_global_mouse_position()
	if Input.is_action_pressed("click"):
		construct(%Area.get_overlapping_bodies(), _polygon_to_global(%Colli.polygon),$Selector)
		
	if Input.is_action_pressed("rclick"):
		destruct(%Area.get_overlapping_bodies(), _polygon_to_global(%Colli.polygon))
