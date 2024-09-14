class_name Map_data
extends Resource

@export var Terrain:Dictionary #{Vector2i : Array[Block_data]}

@export var Map_size:Vector2i
@export var BlockSize:Vector2i

@export var test_value:int



func Write_in_BlockData(id:Vector2i, new_block:Block_data): # 添加方塊的接口
	
	var new:Array[Block_data] = []
	if Terrain.has(id):
		var old:Array[Block_data] = Terrain[id]
		for i:Block_data in old: # 切割所有舊方塊
			var pos = i.position
			var type = i.type
			var new_polygons = Geometry2D.clip_polygons(i.polygon, new_block.polygon)
			for j in new_polygons:
				var data = Block_data.new()
				data.position = pos
				data.type = type
				data.polygon = j
				new.append(data)
	new.append(new_block) # 添加新方塊
	Terrain[id] = new

func Write_empty_data(id:Vector2i):
	if !Terrain.has(id):
		Terrain[id] = []
	

var NAVIGATION := preload("res://map_node/Navigation/navigation.tscn")
var BLOCK_SCENE := preload("res://map_node/block/block.tscn")
func full_load()-> Node2D:
	var root := Node2D.new()
	print("load ", Terrain.size(), " blocks")
	
	for i:Vector2i in Terrain.keys():
		
		var nav_node = NAVIGATION.instantiate()
		nav_node.BlockSize = BlockSize
		nav_node.GlobalPosition = i * BlockSize
		root.add_child(nav_node)
		
		for j:int in range(Terrain[i].size()):
			var node := BLOCK_SCENE.instantiate()
			nav_node.add_child(node)
			
			node.set_polygon(Terrain[i][j].polygon, false)
			node.set_pos(Terrain[i][j].position)
			node.set_type(Terrain[i][j].type)
			
			#blocks[i] = node
		
	return root
#
#func get_blocks(global_pos:Vector2i)-> Array[Block]:
	#var arr:Array[Block] = []
	#var fixed:Vector2i = global_pos/ BlockSize
	#for x in range(-1, 2):
		#for y in range(-1, 2):
			#arr.append(blocks[fixed + Vector2i(x,y)])
	#return arr
#func get_chunk():
	#pass
