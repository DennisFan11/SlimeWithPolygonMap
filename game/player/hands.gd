extends Node2D

const MAX = 300 # PIX 距離200pix 的時候手最長

const k = 3.5 #2 or 4
const d = 0.90
const R = 50+20
func _process(delta):
	if $RayCast2D.is_colliding():
		$Line2D.position = to_local($RayCast2D.get_collision_point())
	else:
		$Line2D.position = $RayCast2D.target_position
	
	var rot = (get_global_mouse_position()-global_position).angle()
	$Line2D.rotation = lerp_angle($Line2D.rotation, rot, 20.0*delta)
	$remove.rotation = lerp_angle($Line2D.rotation, rot, 20.0*delta)
	var y_scale = 1.0
	if (get_global_mouse_position()-global_position).x>=0.0:
		y_scale = 1.0
	else:
		y_scale = -1.0
	$Line2D.scale.y = y_scale



func _physics_process(delta):
	var dist = (get_global_mouse_position()-global_position).length()
	var R = clampf(dist/MAX, 0.0, 1.0) * R
	var pos = ((get_global_mouse_position()-global_position).normalized()*R)
	$RayCast2D.target_position = lerp($RayCast2D.target_position, pos, 20.0*delta)
	

func get_hand_point()->Vector2: # Global position
	if $RayCast2D.is_colliding():
		return $RayCast2D.get_collision_point()
	else:
		return to_global($RayCast2D.target_position)
func get_global_points():
	var arr = []
	for i in $Line2D.points:
		arr.append($Line2D.to_global(i))
	var remove_arr = []
	for i in $remove.points:
		remove_arr.append($remove.to_global(i))
	var final = Geometry2D.clip_polygons(arr, remove_arr)
	if final.size() == 0:
		return []
	return final[0]
