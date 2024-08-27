class_name Destruction
extends Node2D

func _array_gen():
	var arr = []
	for i in range(Global.item_count):
		arr.append(0)
	return arr


func _polygon_to_global(polygon:PackedVector2Array)-> PackedVector2Array:
	for i in range(polygon.size()):
		polygon[i] = to_global(polygon[i])
	return polygon

func destruct(bodies:Array[Node2D] , global_polygon:PackedVector2Array):
	var arr = _array_gen()
	for i in bodies:
		if i.is_in_group("Block"):
			var block:Block = i.get_parent()
			arr[block.id] += block.clip(global_polygon)
	return arr



func construct(bodies:Array[Node2D] , global_polygon:PackedVector2Array,selector:Area2D):
	var select = null
	for i in selector.get_overlapping_bodies():
		if i.is_in_group("Block"):
			select = i.get_parent()
			break
	if !select:
		return
	
	
	for i in bodies:
		if i.is_in_group("Block"):
			var block:Block = i.get_parent()
			if select == block:
				select.merge(global_polygon)
				continue
			elif block.id == select.id:
				block.merge(global_polygon)
				select.no_optimize_merge(block.get_polygon())
				block.queue_free()
				continue
			else:
				block.clip(global_polygon)
	
