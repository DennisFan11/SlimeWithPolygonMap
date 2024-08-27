extends Node

const SCAN_R = 60
const RAY_COUNT = 80
var raycasts:Array[RayCast2D] = []
func _ready():
	for i in range(RAY_COUNT):
		var node = RayCast2D.new()
		raycasts.append(node)
		$Node2D.add_child(node)
		
		node.target_position = Vector2(cos(i*2*PI/RAY_COUNT), sin(i*2*PI/RAY_COUNT))*SCAN_R


func _process(delta):
	$Node2D.global_position = $Node2D.get_global_mouse_position()
func Get_closest_point():
	var center = $Node2D.global_position
	var arr = []
	for i in raycasts:
		if i.is_colliding():
			arr.append(i.get_collision_point())
	if arr.size()==0:
		return Vector2.ZERO
	var dist = func(a:Vector2,b:Vector2): #最短距離排序
		if (a-center).length()< (b-center).length():
			return true
		return false
	arr.sort_custom(dist)
	return arr[0]
