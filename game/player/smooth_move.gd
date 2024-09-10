extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var vec = Input.get_vector("a", "d", "w", "s")
	if vec.length() != 0.0:
		for i in $scanner.get_overlapping_bodies():
			if i.is_in_group("Block"):
				return
		
		var arr = []
		for i in $remove/CollisionPolygon2D.polygon:
			arr.append(to_global(i))
		for i in $remove.get_overlapping_bodies():
			if i.is_in_group("Block"):
				i.get_parent().after_optimize_clip(arr)
