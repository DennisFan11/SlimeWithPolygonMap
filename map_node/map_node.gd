class_name Map_node
extends Node2D

var Resolution:Vector2i
var BlockSize:Vector2i
var Block_node:Node2D

func _ready():
	Block_node = $CanvasGroup
	#Block_node = self # TEST FIXME
	_load()
	
#func get_blocks(global_pos:Vector2i)-> Array[Block]: # 委派
	#return data.get_blocks(global_pos)


var data:Terrain_data
func _load()-> void:
	data = ResourceLoader.load("res://save_map.tres", "Terrain_data")
	print("code: ", data.test_value) # 13 = ok
	
	Block_node.add_child(data.full_load())
	
	Resolution = data.Resolution
	BlockSize = data.BlockSize
	
func _save()-> void: #FIXME
	pass
