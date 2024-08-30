extends Node2D


# 玩家腳色控制器
func _polygon_to_local(polygon:PackedVector2Array)->PackedVector2Array:
	var arr = []
	var node := $CharacterBody2D
	for i in polygon:
		arr.append(node.to_local(i))
	return arr

var max_speed:float = 330.0
var increase:float = 0.17
var decrease:float = 0.45

var gravity:float = max_speed*7.0
var jump_speed:float = gravity/3.0 # 瞬時速度2.0

func _SkinUpdate():
	var slime = $CharacterBody2D/components/slime
	
	var center = slime.Center
	var polygon = slime.Polygon
	var curved_polygon = slime.CurvedPolygon
	
	var hand = _polygon_to_local($CharacterBody2D/Body/Hands.get_global_points())
	polygon = Geometry2D.merge_polygons(hand, polygon)[0]
	
	$CharacterBody2D/Body/SlimeSkin.polygon = polygon
	$CharacterBody2D/Body/SlimeFace.position = center
	$CharacterBody2D/Body/Hands.position = center+ Vector2(0.0, -10)
	$CharacterBody2D/Body/SlimeBoard.points = curved_polygon
	$CharacterBody2D/Body/SlimeBoard_with_hand.points = polygon

func _physics_process(delta):
	var vec = Input.get_vector("a", "d", "w", "s")
	var jump = Input.is_action_just_pressed("space")
	
	var curr = $CharacterBody2D.velocity
	
	if vec.x != 0:
		curr.x = lerpf(curr.x, max_speed * vec.x, increase)
	else: # STOP
		curr.x = lerpf(curr.x, 0.0, decrease)
	if jump:
		curr.y = -jump_speed
	curr.y += gravity * delta
	$CharacterBody2D.velocity = curr
	
	$CharacterBody2D.move_and_slide()
	_SkinUpdate()
	_gun_move()
	
func _input(event):
	if event.is_action("zoom_in"):
		$CharacterBody2D/Equipments/Unbind/Camera2D.zoom *= 1.05
	elif event.is_action("zoom_out"):
		$CharacterBody2D/Equipments/Unbind/Camera2D.zoom *= 0.95
#func _process(delta):
	#var vec :Vector2= $CharacterBody2D.velocity
	#$CharacterBody2D/Body.material.set_shader_parameter("offset",vec.length()/250.0)
	#$CharacterBody2D/Body.material.set_shader_parameter("angle",vec.angle())

func get_hand_position(): # Global position
	return $CharacterBody2D/Body/Hands.get_hand_point()

func _gun_move(): # TEST gun move
	var pos = get_hand_position()
	var gun_node = $CharacterBody2D/Equipments/Unbind/Shotgun
	gun_node.Target = pos
	gun_node.Origin = $CharacterBody2D.global_position
	
func _process(delta):
	_camera_move(delta)
	$CharacterBody2D/Label.text = str(Vector2i($CharacterBody2D.global_position))
func _unhandled_input(event): # TEST gun move
	if event.is_action_pressed("click"):
		var vec = $CharacterBody2D/Equipments/Unbind/Shotgun._shoot()
		if vec != Vector2.ZERO:
			var pos = get_hand_position()
			$CharacterBody2D/Body/Hands/RayCast2D.target_position -= vec
			$CharacterBody2D.velocity -= vec*20 #10
			$CharacterBody2D/components/slime.Splash(pos, vec)
			apply_shake()
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
