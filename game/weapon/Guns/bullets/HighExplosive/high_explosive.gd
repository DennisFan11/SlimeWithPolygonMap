extends CharacterBody2D
var Speed:Vector2 = Vector2.ZERO



func _physics_process(delta):
	velocity = Speed
	move_and_slide()


var particle := preload("res://game/weapon/Guns/particle/exlpo.tscn")
func explo():
	var node := particle.instantiate()
	Global.ParticleNode.MetaSmoke.add_child(node)
	node.global_position = global_position
	node.connect("finished", node.queue_free)
	node.emitting = true
	queue_free()

func _on_timer_timeout():
	queue_free()

func _clip_gen()->PackedVector2Array:
	const R = 20.0 #30
	const POINT_COUNT = 12
	var arr = []
	for i in range(POINT_COUNT):
		var angle = i*PI*2.0/POINT_COUNT
		arr.append(to_global(Vector2(cos(angle), sin(angle))*R))
	return arr



func _on_colli_scan_body_entered(body:Node2D):
	if body.is_in_group("Block"):
		var block:Block = body.get_parent()
		if !block.Busy:
			#block.clip(_clip_gen())
			block.after_optimize_clip(_clip_gen())
			
			explo()
		
		
		
		
		
		
