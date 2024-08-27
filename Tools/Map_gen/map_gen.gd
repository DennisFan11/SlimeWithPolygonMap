extends Node2D
@onready var world:Sprite2D = $SubViewportContainer/SubViewport/world
@onready var viewport:SubViewport = $SubViewportContainer/SubViewport
@onready var camera:Camera2D = $SubViewportContainer/SubViewport/Camera2D

var Resolution:int = 100 : #pix
	set(new):
		Resolution = new
		_world_update()
var Block_size:int = 100: #pix
	set(new):
		Block_size = new
		_world_update()






func _on_radius_value_changed(value):
	Resolution = value
func _on_block_size_value_changed(value):
	Block_size = value

func _world_update()->void :
	var vec := Vector2.ONE * Resolution
	camera.offset = vec / 2
	camera.zoom = Vector2.ONE
	world.position = vec / 2
	world.scale = vec / 512.0
	
enum {COPPER, IORN, COAL, ROCK, LUMIUM, BIOMASS}
const colors = {
	IORN: Color("7f7f7f"),
	COPPER: Color("ae5e3e"),
	LUMIUM: Color("0c8599"),
	ROCK: Color("846358"),
	COAL: Color("191919")
}
func _set_color():
	world.material.set_shader_parameter("Iorn", colors[IORN])
	world.material.set_shader_parameter("Copper", colors[COPPER])
	world.material.set_shader_parameter("Lumium", colors[LUMIUM])
	world.material.set_shader_parameter("Stone", colors[ROCK])
	world.material.set_shader_parameter("Coal", colors[COAL])

func _ready():
	var resolution = $Control/Panel/VBoxContainer/Resolution
	var block_size = $Control/Panel/VBoxContainer/BlockSize
	resolution.value = Resolution
	block_size.value = Block_size
	_world_update()
	_set_color()
func _process(delta):
	camera.offset += Input.get_vector("a", "d", "w", "s")*delta*200
func _input(event):
	if event.is_action("zoom_in"):
		camera.zoom *= 1.05
	elif event.is_action("zoom_out"):
		camera.zoom *= 0.95

	
func _on_save_button_down(): # SAVE MAP
	var data := await _map_data_gen()
	data.test_value = 13
	# 使用 ResourceSaver 保存资源
	var error = ResourceSaver.save(data, "res://save_map.tres",0)
	if error == OK:
		print("Resource saved successfully!")
	else:
		print("Failed to save resource: ", error)
	_world_update()


func _get_img(pos:Vector2i, size:Vector2i)-> Image:
	var vec := Vector2.ONE * Resolution
	
	camera.offset = pos + (size/2)
	camera.zoom = Vector2.ONE
	world.position = vec / 2
	world.scale = vec / 512.0
	viewport.size = size
	
	await RenderingServer.frame_post_draw
	return viewport.get_texture().get_image()



func _map_data_gen()-> Terrain_data:
	var terrain_data := Terrain_data.new()
	
	var square = PackedVector2Array([
		Vector2(0.0, 0.0),
		Vector2(Block_size, 0.0),
		Vector2(Block_size, Block_size),
		Vector2(0.0, Block_size)
	])
	var faild = 0
	var saved = 0
	
	var cut_size = Vector2i(100,100)
	for block_x:int in range(0, Resolution, cut_size.x):
		for block_y:int in range(0, Resolution, cut_size.y):
			var block_pos := Vector2i(block_x, block_y)
			var map_img := await _get_img(block_pos, cut_size)# pixel
			print("cutting pos: ", block_pos)
			
			for x in range(block_pos.x, block_pos.x + cut_size.x):
				for y in range(block_pos.y, block_pos.y + cut_size.y):
					# 填充block
					var block := Block_data.new()
					var pixel := map_img.get_pixelv(Vector2i(x,y)%cut_size)
					block.position = Vector2i(x,y) * Block_size
					block.polygon = square
			
					block.type = -1 # Color match
					for i in colors.keys():
						if colors[i].is_equal_approx(pixel):
							block.type = i
							saved+=1
					if block.type == -1:
						if pixel== Color(0,0,0,0) or pixel == Color(0,0,0,1): continue
						#print("pixel match faild! ", pixel)
						faild+=1
						continue
					terrain_data.blocks[Vector2i(x,y)] = block
					
	terrain_data.BlockSize = Vector2.ONE * Block_size
	terrain_data.Resolution = Vector2.ONE * Resolution
	
	print(saved, " block saved!")
	print(faild, " block faild!")
	print("size = ", terrain_data.blocks.size())
	#map_img.save_png("check.png")
	return terrain_data
