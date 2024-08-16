class_name Destruction
extends Node2D




func _polygon_to_global(polygon:PackedVector2Array)-> PackedVector2Array:
	for i in range(polygon.size()):
		polygon[i] = to_global(polygon[i])
	return polygon

func destruct(bodies:Array[Node2D] , global_polygon:PackedVector2Array):
	for i in bodies:
		if i.is_in_group("Block"):
			var block:Block = i.get_parent()
			block.clip(global_polygon)
func construct(bodies:Array[Node2D] , global_polygon:PackedVector2Array):
	for i in bodies:
		if i.is_in_group("Block"):
			var block:Block = i.get_parent()
			block.merge(global_polygon)
			return
