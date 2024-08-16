class_name Map_node
extends Node2D


func _ready():
	_load()
	
#func get_blocks(global_pos:Vector2i)-> Array[Block]: # 委派
	#return data.get_blocks(global_pos)


var data:Terrain_data
func _load()-> void:
	var data = ResourceLoader.load("res://save_map.tres", "Terrain_data")
	print("code: ", data.test_value) # 13 = ok
	add_child(data.full_load())
	
	
func _save()-> void: #FIXME
	pass
