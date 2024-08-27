extends Node2D


# 玩家腳色控制器



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
	
	$CharacterBody2D/Body/SlimeSkin.polygon = polygon
	$CharacterBody2D/Body/SlimeFace.position = center
	$CharacterBody2D/Body/SlimeBoard.points = curved_polygon





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
	
	
func _input(event):
	if event.is_action("zoom_in"):
		$CharacterBody2D/Camera2D.zoom *= 1.05
	elif event.is_action("zoom_out"):
		$CharacterBody2D/Camera2D.zoom *= 0.95
