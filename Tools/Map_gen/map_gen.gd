extends Node2D
@onready var viewport:SubViewport = $SubViewportContainer/SubViewport
@onready var camera:Camera2D = $SubViewportContainer/SubViewport/Camera2D

var Map_size:int = 40 #pix 100
var Block_size:int = 250 #pix 100
var Scan_precision:int = 100



func _on_radius_value_changed(value):
	Map_size = value
func _on_block_size_value_changed(value):
	Block_size = value


#enum _old{COPPER, IORN, COAL, ROCK, LUMIUM, BIOMASS}
#const colors_old = {
	#IORN: Color("7f7f7f"),
	#COPPER: Color("ae5e3e"),
	#LUMIUM: Color("0c8599"),
	#ROCK: Color("846358"),
	#COAL: Color("191919")
#}
enum {DIRT, STONE, COPPER, IORN, COAL}
const colors = {
	DIRT:Color(0.68, 0.36, 0.24),
	STONE:Color(0.5,0.5,0.5),
	COPPER:Color(0.914, 0.6, 0.3),
	IORN:Color(0.2, 0.2, 0.2),
	COAL:Color(0.1, 0.1, 0.1)
}
func _ready():
	var resolution = $Control/Panel/VBoxContainer/Resolution
	var block_size = $Control/Panel/VBoxContainer/BlockSize
	resolution.value = Map_size
	block_size.value = Block_size
func _process(delta):
	camera.offset += Input.get_vector("a", "d", "w", "s")*delta*200
func _input(event):
	if event.is_action("zoom_in"):
		camera.zoom *= 1.05
	elif event.is_action("zoom_out"):
		camera.zoom *= 0.95

	
func _on_save_button_down(): # SAVE MAP
	var data := await _map_data_gen()
	
	# 使用 ResourceSaver 保存资源
	var error = ResourceSaver.save(data, "res://save_map.tres",0)
	if error == OK:
		print("Resource saved successfully!")
	else:
		print("Failed to save resource: ", error)


func _get_polygons(block_id:Vector2, sprite:Sprite2D)-> Array[PackedVector2Array]:
	var vec := Vector2.ONE * Map_size* Scan_precision
	sprite.visible = true
	sprite.position = vec / 2
	sprite.scale = vec / 512.0
	
	camera.offset = block_id* Scan_precision + Vector2.ONE * (Scan_precision/2)
	camera.zoom = Vector2.ONE
	
	viewport.size = Vector2.ONE * Scan_precision
	
	await RenderingServer.frame_post_draw
	var img = viewport.get_texture().get_image()
	sprite.visible = false
	
	var bitmap = BitMap.new()
	bitmap.create_from_image_alpha(img)
	#img.save_png("res://cuts/" + str(block_id.x*10000 + block_id.y)+".png")
	var polygons = bitmap.opaque_to_polygons(Rect2(Vector2(), bitmap.get_size()))
	for i in range(polygons.size()): # Re_scale
		for j in polygons[i].size():
			polygons[i][j] *= float(Block_size)/float(Scan_precision)
	return polygons



func _map_data_gen()-> Map_data:
	var map_data = Map_data.new()
	var sprites = [
		$SubViewportContainer/SubViewport/Dirt,
		$SubViewportContainer/SubViewport/Stone,
		$SubViewportContainer/SubViewport/Copper,
		$SubViewportContainer/SubViewport/Iorn,
		$SubViewportContainer/SubViewport/Coal
	]
	for i:Sprite2D in sprites:
		i.visible = false
	var terrain_count:int = 0
	for block_x:int in range(0, Map_size):
		for block_y:int in range(0, Map_size):
			var block_id := Vector2i(block_x, block_y)
			var block_position = block_id * Block_size
			print("generating: ",block_id)
			
			for id in range(sprites.size()):
				var polygons := await _get_polygons(block_id, sprites[id])
				for i in polygons:
					var block := Block_data.new()
					block.position = block_position
					block.polygon = i
					block.type = id
					
					map_data.Write_in_BlockData(block_id, block)
					terrain_count+= 1
	for i:Sprite2D in sprites:
		i.visible = true
	
	map_data.BlockSize = Vector2.ONE * Block_size
	map_data.Map_size = Vector2.ONE * Map_size
	map_data.test_value = 13
	#print("blocks:",  map_data.blocks.size())
	print("terrain:", terrain_count)
	return map_data
