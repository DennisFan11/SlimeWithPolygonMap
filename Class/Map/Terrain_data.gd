class_name Terrain_data
extends Resource

@export var blocks:Dictionary #[Vector2i, Block_data]
@export var Resolution:Vector2i
@export var BlockSize:Vector2i

@export var test_value:int

var BLOCK_SCENE := preload("res://map_node/block/block.tscn")
func full_load()-> Node2D:
	var root := Node2D.new()
	print("load ", blocks.size(), " blocks")
	for i:Vector2i in blocks.keys():
		var node := BLOCK_SCENE.instantiate()
		root.add_child(node)
		
		node.set_polygon(blocks[i].polygon)
		node.set_pos(blocks[i].position)
		node.set_type(blocks[i].type)
		
		blocks[i] = node
	return root

func get_blocks(global_pos:Vector2i)-> Array[Block]:
	var arr:Array[Block] = []
	var fixed:Vector2i = global_pos/ BlockSize
	for x in range(-1, 2):
		for y in range(-1, 2):
			arr.append(blocks[fixed + Vector2i(x,y)])
	return arr
