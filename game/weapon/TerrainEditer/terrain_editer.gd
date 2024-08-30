extends Destruction
const POINT_SIZE = 20 #20

enum {CIRCLE, SQUARE, CIRCLE_LINE, SQUARE_LINE}
var Shape:int = SQUARE_LINE:
	set(new):
		Shape = new
		_update()
var R = 70.0: #70
	set(new):
		R = new
		_update()
var Block_ID:int = 0:
	set(new):
		Block_ID = new
		_update()
var Expand:bool = false:
	set(new):
		Expand = new
		_update()




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

func _circle_init():
	var arr = []
	for i in range(POINT_SIZE):
		var angle = PI*2 / POINT_SIZE * i
		arr.append(Vector2(cos(angle) * R, sin(angle) * R))
	%Colli.polygon = arr
func _square_init():
	%Colli.polygon = PackedVector2Array([Vector2(-R,-R), Vector2(R,-R), Vector2(R,R), Vector2(-R,R)])
func _circle_line_gen(first:Vector2, second:Vector2):
	var arr = []
	
	for i in range(POINT_SIZE):
		var angle = PI*2 / POINT_SIZE * i
		var pos = Vector2(cos(angle) * R, sin(angle) * R) + first
		
		var a = pos - first
		var b = second - first
		if a.dot(b) > 0:
			continue
		arr.append(pos)
	
	for i in range(POINT_SIZE):
		var angle = PI*2 / POINT_SIZE * i
		var pos = Vector2(cos(angle) * R, sin(angle) * R) + second
		
		var a = pos - second
		var b = first - second 
		if a.dot(b) > 0:
			continue
		arr.append(pos)
	return _sort_points(arr)
func _square_line_gen(first:Vector2, second:Vector2):
	var arr = []
	
	for i in [Vector2(-R,-R), Vector2(R,-R), Vector2(R,R), Vector2(-R,R)]:
		var pos = i + first
		
		var a = pos - first
		var b = second - first
		if a.dot(b) > 0:
			continue
		arr.append(pos)
	
	for i in [Vector2(-R,-R), Vector2(R,-R), Vector2(R,R), Vector2(-R,R)]:
		var pos = i + second
		
		var a = pos - second
		var b = first - second 
		if a.dot(b) > 0:
			continue
		arr.append(pos)
	return _sort_points(arr)


func _update():
	if Shape == CIRCLE:
		_circle_init()
	elif Shape == SQUARE:
		_square_init()
	
	




func _ready():
	_update()

func _physics_process(delta):
	global_position = get_global_mouse_position()
	
	if Shape == SQUARE or Shape == CIRCLE:
		if Lclicking: # 新增
			if Expand:
				construct(%Area.get_overlapping_bodies(), _polygon_to_global(%Colli.polygon),$Selector)
			else:
				new_construct(%Area.get_overlapping_bodies(), _polygon_to_global(%Colli.polygon), Block_ID)
			
		if Rclicking: # 裁減
			destruct(%Area.get_overlapping_bodies(), _polygon_to_global(%Colli.polygon))
	
	
	
	
	
	if Lclicking and Shape == CIRCLE_LINE:
		$Node/Polygon2D.color = Color('ffffff95')
		$Node/Polygon2D.polygon = _circle_line_gen(first_point, get_global_mouse_position())
	elif Rclicking and Shape == CIRCLE_LINE:
		$Node/Polygon2D.color = Color('ff280095')
		$Node/Polygon2D.polygon = _circle_line_gen(del_first_point, get_global_mouse_position())
	elif Lclicking and Shape == CIRCLE:
		$Node/Polygon2D.color = Color('ffffff95')
		$Node/Polygon2D.polygon = _circle_line_gen(get_global_mouse_position(), get_global_mouse_position())
	elif Rclicking and Shape == CIRCLE:
		$Node/Polygon2D.color = Color('ff280095')
		$Node/Polygon2D.polygon = _circle_line_gen(get_global_mouse_position(), get_global_mouse_position())
	
	if Lclicking and Shape == SQUARE_LINE:
		$Node/Polygon2D.color = Color('ffffff95')
		$Node/Polygon2D.polygon = _square_line_gen(first_point, get_global_mouse_position())
	elif Rclicking and Shape == SQUARE_LINE:
		$Node/Polygon2D.color = Color('ff280095')
		$Node/Polygon2D.polygon = _square_line_gen(del_first_point, get_global_mouse_position())
	elif Lclicking and Shape == SQUARE:
		$Node/Polygon2D.color = Color('ffffff95')
		$Node/Polygon2D.polygon = _square_line_gen(get_global_mouse_position(), get_global_mouse_position())
	elif Rclicking and Shape == SQUARE:
		$Node/Polygon2D.color = Color('ff280095')
		$Node/Polygon2D.polygon = _square_line_gen(get_global_mouse_position(), get_global_mouse_position())
	if !Rclicking and !Lclicking:
		if Shape == CIRCLE or Shape == CIRCLE_LINE:
			$Node/Polygon2D.color = Color('ffffff95')
			$Node/Polygon2D.polygon = _circle_line_gen(get_global_mouse_position(), get_global_mouse_position())
		elif Shape == SQUARE or SQUARE_LINE:
			$Node/Polygon2D.color = Color('ffffff95')
			$Node/Polygon2D.polygon = _square_line_gen(get_global_mouse_position(), get_global_mouse_position())
var Lclicking:bool = false
var Rclicking:bool = false
	
var first_point:Vector2
var second_point:Vector2
func _draw_line():
	if Shape == CIRCLE_LINE:
		$Node/LineArea/CollisionPolygon2D.polygon = _circle_line_gen(first_point, second_point)
		await get_tree().physics_frame
		await get_tree().physics_frame
		if Expand:
			construct($Node/LineArea.get_overlapping_bodies(),
				$Node/LineArea/CollisionPolygon2D.polygon,
				$Selector)
		else:
			new_construct($Node/LineArea.get_overlapping_bodies(),
				$Node/LineArea/CollisionPolygon2D.polygon,
				Block_ID)
	elif Shape == SQUARE_LINE:
		$Node/LineArea/CollisionPolygon2D.polygon = _square_line_gen(first_point, second_point)
		await get_tree().physics_frame
		await get_tree().physics_frame
		if Expand:
			construct($Node/LineArea.get_overlapping_bodies(),
				$Node/LineArea/CollisionPolygon2D.polygon,
				$Selector)
		else:
			new_construct($Node/LineArea.get_overlapping_bodies(),
				$Node/LineArea/CollisionPolygon2D.polygon,
				Block_ID)
func _delete_line():
	if Shape == CIRCLE_LINE:
		$Node/LineArea/CollisionPolygon2D.polygon = _circle_line_gen(del_first_point, del_second_point)
		await get_tree().physics_frame
		await get_tree().physics_frame
		destruct($Node/LineArea.get_overlapping_bodies(),
			$Node/LineArea/CollisionPolygon2D.polygon)
	elif Shape == SQUARE_LINE:
		$Node/LineArea/CollisionPolygon2D.polygon = _square_line_gen(del_first_point, del_second_point)
		await get_tree().physics_frame
		await get_tree().physics_frame
		destruct($Node/LineArea.get_overlapping_bodies(),
			$Node/LineArea/CollisionPolygon2D.polygon)

var del_first_point:Vector2
var del_second_point:Vector2


func _unhandled_input(event):
	#if event.is_action_pressed("zoom_in"):
		#R*=1.1
		#get_viewport().set_input_as_handled()
	#elif event.is_action_pressed("zoom_out"):
		#R*=0.9
		#get_viewport().set_input_as_handled()
	if event.is_action_pressed("click"):
		first_point = get_global_mouse_position()
		Lclicking = true
	elif event.is_action_released("click"):
		second_point = get_global_mouse_position()
		_draw_line()
		Lclicking = false
	elif event.is_action_pressed("rclick"):
		del_first_point = get_global_mouse_position()
		Rclicking = true
	elif event.is_action_released("rclick"):
		del_second_point = get_global_mouse_position()
		_delete_line()
		Rclicking = false
	elif event.is_action_pressed("esc"):
		queue_free()
	else:
		return
	get_viewport().set_input_as_handled()
	
	
	
	
	
	
