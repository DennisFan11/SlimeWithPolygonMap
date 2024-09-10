extends Node2D


# 玩家腳色控制器


var max_speed:float = 330.0
var increase:float = 0.17
var decrease:float = 0.45

var gravity:float = max_speed*7.0
var jump_speed:float = gravity/3.0 # 瞬時速度2.0

func to_normal(vec:Vector2,origin:Vector2)->Vector2:
	var angle = (Global.GravityCenter - origin).angle() - Vector2.DOWN.angle()
	return vec.rotated(-1.0*angle)
	
func to_world(vec:Vector2,origin:Vector2)->Vector2:
	var angle = (Global.GravityCenter - origin).angle() - Vector2.DOWN.angle()
	return vec.rotated(1.0*angle)

func _physics_process(delta):
	Global.PlayerPosition = $CharacterBody2D.global_position
	# 计算角色相对于重力中心的角度
	var dir_to_center = (Global.GravityCenter - $CharacterBody2D.global_position)
	var angle = dir_to_center.angle()
	var trans_angle = angle - Vector2.DOWN.angle()
	var rotate_angle = angle - PI/2.0
	$CharacterBody2D.rotation = rotate_angle 
	$CharacterBody2D/Equipments/Unbind/Camera2D.rotation = rotate_angle # FIXME
	$CharacterBody2D.up_direction = dir_to_center.normalized()*-1.0
	
	# 获取输入向量
	var vec = Input.get_vector("a", "d", "w", "s")
	var jump = Input.is_action_just_pressed("space")
	
	# 获取当前速度
	var curr :Vector2 = $CharacterBody2D.velocity
	
	angle = (Global.GravityCenter - $CharacterBody2D.global_position).angle()
	
	# 将速度矢量转换到与重力方向对齐的坐标系
	curr = curr.rotated(-1.0*trans_angle)
	
	if vec.x != 0: # 处理左右移动
		curr.x = lerp(curr.x, max_speed * vec.x, increase)
	else: # 停止移动
		curr.x = lerp(curr.x, 0.0, decrease)
	if jump: # 处理跳跃
		curr.y = -jump_speed
	curr.y += gravity * delta # 施加重力
	
	# 将速度矢量转换回世界坐标系
	curr = curr.rotated(1*trans_angle)
	
	# 更新速度
	$CharacterBody2D.velocity = curr
	$CharacterBody2D.move_and_slide()# 移动角色并处理碰撞
	# 额外的更新函数
	_SkinUpdate()
	_gun_move()

func _process(delta):
	_camera_move(delta)
	$CharacterBody2D/Label.text = str(Vector2i($CharacterBody2D.global_position))
	
	#var vec :Vector2= $CharacterBody2D.velocity
	#$CharacterBody2D/Body.material.set_shader_parameter("offset",vec.length()/250.0)
	#$CharacterBody2D/Body.material.set_shader_parameter("angle",vec.angle())


func get_hand_position(): # Global position
	return $CharacterBody2D/Body/Hands.get_hand_point()
func _polygon_to_local(polygon:PackedVector2Array)->PackedVector2Array:
	var arr = []
	var node := $CharacterBody2D
	for i in polygon:
		arr.append(node.to_local(i))
	return arr


func _SkinUpdate():
	var slime = $CharacterBody2D/components/slime
	
	var center = slime.Center
	var polygon = slime.Polygon
	var curved_polygon = slime.CurvedPolygon
	
	var hand = _polygon_to_local($CharacterBody2D/Body/Hands.get_global_points())
	var cah = Geometry2D.merge_polygons(hand, polygon)
	if cah.size() != 0:
		polygon = cah[0]
	
	$CharacterBody2D/Body/SlimeSkin.polygon = polygon
	$CharacterBody2D/Body/SlimeFace.position = center
	$CharacterBody2D/Body/Hands.position = center+ Vector2(0.0, -10)
	$CharacterBody2D/Body/SlimeBoard.points = curved_polygon
	$CharacterBody2D/Body/SlimeBoard_with_hand.points = polygon

func _gun_move(): # TEST gun move
	var pos = get_hand_position()
	var gun_node = $CharacterBody2D/Equipments/Unbind/Shotgun
	gun_node.Target = pos
	gun_node.Origin = $CharacterBody2D.global_position
	



func _input(event):
	if event.is_action("zoom_in"):
		$CharacterBody2D/Equipments/Unbind/Camera2D.zoom *= 1.05
	elif event.is_action("zoom_out"):
		$CharacterBody2D/Equipments/Unbind/Camera2D.zoom *= 0.95
func _unhandled_input(event): # TEST gun move
	if event.is_action_pressed("click"):
		
		var vec = $CharacterBody2D/Equipments/Unbind/Shotgun._shoot()
		if vec != Vector2.ZERO:
			var pos = get_hand_position()
			var fix_ = to_normal(vec, $CharacterBody2D/Body/Hands/RayCast2D.global_position)
			
			$CharacterBody2D/Body/Hands/RayCast2D.target_position -= fix_
			$CharacterBody2D.velocity -= vec*0.0 #10 20
			$CharacterBody2D/components/slime.Splash(pos, -vec)
			#apply_shake()
	if event.is_action_pressed("R"):
		$CharacterBody2D/Equipments/Unbind/Shotgun._reload()



const CAMERA_SPEED:float = 20.0
const RANDOM_SHAKE_STRENGTH:float = 5.0
const SHAKE_DECAY_RATE: float = 5.0
var shake_strength: float = 0.0

func apply_shake() -> void:
	shake_strength = RANDOM_SHAKE_STRENGTH

func _camera_move(delta:float):
	var camera := $CharacterBody2D/Equipments/Unbind/Camera2D
	shake_strength = lerpf(shake_strength, 0.0, SHAKE_DECAY_RATE * delta)
	camera.offset = get_random_offset()
	camera.position = camera.position.lerp($CharacterBody2D.global_position, delta*CAMERA_SPEED)
func get_random_offset() -> Vector2:
	return Vector2(
		randf_range(-shake_strength, shake_strength),
		randf_range(-shake_strength, shake_strength)
	)
