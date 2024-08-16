extends Node2D


func _sort_points(array:Array)->PackedVector2Array: # 計算順時針多邊形
	"""
	// 輸入: 2點座標 (全域座標)
	輸出: 順時針多邊形 points
	"""
	var cp = Vector2.ZERO
	for i in array:
		cp+=i
	cp/=array.size()
	var center_angle_sort = func(A:Vector2,B:Vector2) -> bool: # 中心最大角度排序 lambda (順時鐘)
		var Aang:float = (A-cp).angle()
		var Bang:float = (B-cp).angle()
		return Aang >= Bang
	array.sort_custom(center_angle_sort)# (順時鐘排序)
	return PackedVector2Array(array)


var scene = preload("res://game/procedural_animation/slime/slime_body/slime_body.tscn")
var points = []
func _ready():
	const POINT_SIZE = 30 #30
	const R = 50
	for i in range(POINT_SIZE):
		var node := scene.instantiate()
		points.append(node)
		$Node.add_child(node)
		var angle = PI*2 / POINT_SIZE * i
		
		node.position = to_global(Vector2(cos(angle)*R, sin(angle)*R))
		node.origin = Vector2(cos(angle)*R, sin(angle)*R)
		
var k = 3.5 #2 or 4
var d = 0.90
var spread = 0.35 # 0.2
var passes = 3 # 5
func _process(delta):
	
	var polygon = []
	for i in points:
		i.fixed_origin = to_global(i.origin)
		i.center = global_position
		i.slime_update(k, d)
		polygon.append(i.global_position)
	
	polygon = _sort_points(polygon)
	var curve = Curve2D.new()
	for i in polygon:
		curve.add_point(i)
	
	$Node/Polygon2D.polygon = curve.get_baked_points()
	
#region 動力傳播
	for p in range(passes):
		var new_delta = []
		for i in range(points.size()):
			new_delta.append(0)
		var min_delta = []
		for i in range(points.size()):
			min_delta.append(0)
		
		for i in range(points.size()):
			if i != points.size()-1:
				new_delta[i+1] += (spread * (points[i].get_height() - points[i+1].get_height()))
				min_delta[i] += (spread * (points[i].get_height() - points[i+1].get_height()))
				new_delta[i-1] += (spread * (points[i].get_height() - points[i-1].get_height()))
				min_delta[i] += (spread * (points[i].get_height() - points[i-1].get_height()))
			else: #最後一個
				new_delta[0] += (spread * (points[i].get_height() - points[0].get_height()))
				min_delta[i] += (spread * (points[i].get_height() - points[0].get_height()))
				new_delta[i-1] += (spread * (points[i].get_height() - points[i-1].get_height()))
				min_delta[i] += (spread * (points[i].get_height() - points[i-1].get_height()))
		
		for i in range(points.size()):
			points[i].set_height(new_delta[i] - min_delta[i])
#endregion
		
	
	
	
	
	
	
	
	
	
	
	
	
