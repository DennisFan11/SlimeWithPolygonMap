class_name SlimePoint
extends CharacterBody2D
var origin:Vector2 # 本地錨點
var fixed_origin:Vector2 #全域錨點
var center:Vector2 #全域


#hook's law: F = -K * x
#var x = height - target_height
#height = (position - origin).length()


func get_height():
	var A = (global_position - center).normalized()
	var B = (global_position - fixed_origin).normalized()
	return (global_position - fixed_origin).length() * A.dot(B)

func set_height(height:float):
	velocity += (global_position - center).normalized() * height

#
## 获取当前高度
#func get_height():
	#return velocity
#
## 设置目标高度
#func set_height(height):
	#velocity += height
var max_length = 105.0 #70
func slime_update(spring_constant, damping):
	var force = spring_constant * (fixed_origin - global_position)
	velocity += force
	velocity *= damping  # 加入阻尼
	move_and_slide()
	if (fixed_origin - global_position).length() >= max_length:
		global_position = center#fixed_origin
