extends Node2D
var BLOCK_SCENE := preload("res://map_node/block/block.tscn")

func _ready():
	_load()
func _load()-> void:
	var file:Map_data = ResourceLoader.load("res://save_map.tres", "Map_data")
	print(file.test)
	for i:Block_data in file.blocks:
		var node = BLOCK_SCENE.instantiate()
		add_child(node)
		node.set_block(i)
	
func _save()-> void:
	pass
