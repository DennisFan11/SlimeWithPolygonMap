extends CharacterBody2D
var Target:Vector2 = Vector2.ZERO
var Origin:Vector2 = Vector2.ZERO
var Max_length = 200.0

const spring_constant = 20
func to_normal(vec:Vector2,origin:Vector2)->Vector2:
	var angle = (Global.GravityCenter - origin).angle() - Vector2.DOWN.angle()
	return vec.rotated(-1.0*angle)
	
func to_world(vec:Vector2,origin:Vector2)->Vector2:
	var angle = (Global.GravityCenter - origin).angle() - Vector2.DOWN.angle()
	return vec.rotated(1.0*angle)

func _physics_process(delta):
	velocity = (Target-global_position)*spring_constant
	global_rotation = lerp_angle(global_rotation, 
		(get_global_mouse_position()-global_position).angle(),
		spring_constant*delta)
	$Label.text = str(global_rotation)
	if to_normal($Marker2D.global_position - global_position,global_position).x>=0.0:
	#if global_rotation>=PI/2.0 or global_rotation<=-PI/2.0:
		scale.y = 1.0
	else:
		scale.y = -1.0
	move_and_slide()
	if (global_position - Target).length()>Max_length:
		global_position = Origin
var bullet = preload("res://game/weapon/Guns/bullets/HighExplosive/high_explosive.tscn")



const SPEED = 750.0
const COUNT = 8 #8
func _shoot():
	if !_shoot_check():
		return Vector2.ZERO
	var deg = deg_to_rad(15.0)
	var sep = 200.0
	for i in range(COUNT):
		var rand_angle = randf_range(-deg,deg)
		var rand_speed = randf_range(-sep,sep)
		var node = bullet.instantiate()
		node.Speed = Vector2(1.0,0.0).rotated(global_rotation+rand_angle)*(SPEED+rand_speed)
		node.global_position = $Marker2D.global_position
		Global.MainGame.add_child(node)
		#if i %10 == 1:
			#pass
			#await get_tree().physics_frame
	global_position -= Vector2(1.0,0.0).rotated(global_rotation) * 30.0
	
	var vec = 50.0 * ($Marker2D.global_position-global_position).normalized()
	return vec

func _ready():
	$AnimatedSprite2D.frame = 0

var reloading:bool = false
func _reload():
	if !reloading:
		reloading = true
		Ammo = 0
		$AnimatedSprite2D.play("defult")
		var tween = get_tree().create_tween()
		tween.set_trans(Tween.TransitionType.TRANS_BACK)
		tween.tween_property(self, "rotation", rotation+2*PI, 0.6)



func _reload_finish():
	reloading = false
	$AnimatedSprite2D.frame = 0
	Ammo = MAX_AMMO

const MAX_AMMO:int = 5
var Ammo:int = 5
func _shoot_check()->bool:
	if Ammo >= 1:
		Ammo-=1
		$AnimatedSprite2D.frame += 1
		return true
	_reload()
	return false
