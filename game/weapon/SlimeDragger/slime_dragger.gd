extends Node2D

var force = 160.0
func _physics_process(delta):
	$Area2D.global_position = get_global_mouse_position()
	if Input.is_action_pressed("click"):
		for i:Node2D in $Area2D.get_overlapping_bodies():
			if i.is_in_group("slime_body"):
				i.velocity += force * (i.global_position-i.center).normalized()
				#i.velocity += force * (get_global_mouse_position()-i.global_position).normalized()
