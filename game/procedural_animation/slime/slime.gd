extends Node2D

var Center:Vector2
var Polygon:PackedVector2Array
var CurvedPolygon:PackedVector2Array = []

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
		if (A-cp).angle()>=(B-cp).angle():
			return false
		return true
	array.sort_custom(center_angle_sort)# (順時鐘排序)
	return PackedVector2Array(array)



const POINT_SIZE = 30 #30
const R = 50
var scene = preload("res://game/procedural_animation/slime/slime_body/slime_body.tscn")
var point_instans:Array[SlimePoint] = []

func _ready():
	for i in range(POINT_SIZE):
		var node := scene.instantiate()
		point_instans.append(node)
		$Node.add_child(node)
		var angle:float = PI*2 / POINT_SIZE * i
		
		node.position = to_global(Vector2(cos(angle)*R, sin(angle)*R))
		node.origin = Vector2(cos(angle)*R, sin(angle)*R)
		
const k = 3.5 #2 or 4
const d = 0.90
func _physics_process(delta):
	
	var center:Vector2 = Vector2.ZERO
	var polygon:PackedVector2Array = []
	var curved_polygon:PackedVector2Array = []
	
	for i:SlimePoint in point_instans:
		i.fixed_origin = to_global(i.origin)
		i.center = global_position
		i.slime_update(k, d)
		
		var point := to_local(i.global_position)
		center+= point
		polygon.append(point)
		
	center/=polygon.size() # 算出中心點
	
	polygon = _sort_points(polygon) # 極座標排序
	
	var curve = Curve2D.new()
	for i in polygon:
		curve.add_point(i)
	$Node/SmoothPath.curve = curve 
	$Node/SmoothPath.smooth(true)
	curved_polygon = curve.get_baked_points() # 平滑曲線
	
	CurvedPolygon = curved_polygon
	Polygon = polygon
	Center = center
	
	
	
	_wave()


const spread = 0.5 # 0.2 0.35 0.1
const passes = 3 # 5 3 	
func _wave(): # 動量分散
	for p in range(passes):
		var new_delta = []
		for i in range(point_instans.size()):
			new_delta.append(0)
		var min_delta = []
		for i in range(point_instans.size()):
			min_delta.append(0)
		
		for i in range(point_instans.size()):
			if i != point_instans.size()-1:
				new_delta[i+1] += (spread * (point_instans[i].get_height() - point_instans[i+1].get_height()))
				min_delta[i] += (spread * (point_instans[i].get_height() - point_instans[i+1].get_height()))
				new_delta[i-1] += (spread * (point_instans[i].get_height() - point_instans[i-1].get_height()))
				min_delta[i] += (spread * (point_instans[i].get_height() - point_instans[i-1].get_height()))
			else: #最後一個
				new_delta[0] += (spread * (point_instans[i].get_height() - point_instans[0].get_height()))
				min_delta[i] += (spread * (point_instans[i].get_height() - point_instans[0].get_height()))
				new_delta[i-1] += (spread * (point_instans[i].get_height() - point_instans[i-1].get_height()))
				min_delta[i] += (spread * (point_instans[i].get_height() - point_instans[i-1].get_height()))
		
		for i in range(point_instans.size()):
			point_instans[i].set_height(new_delta[i] - min_delta[i])
	

func Splash(global_pos:Vector2, vec:Vector2):
	var copy = point_instans.duplicate(false)
	var dist_sort = func(A:SlimePoint,B:SlimePoint):
		if (A.global_position-global_pos).length()< (B.global_position-global_pos).length():
			return true
		return false
	copy.sort_custom(dist_sort)
	for i in range(3):
		copy[i].global_position += vec
	
	
	
	
	
	
