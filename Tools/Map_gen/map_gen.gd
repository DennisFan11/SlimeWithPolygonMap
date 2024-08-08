extends Node2D
@onready var world:Sprite2D = $SubViewportContainer/SubViewport/world
@onready var viewport:SubViewport = $SubViewportContainer/SubViewport
@onready var camera:Camera2D = $SubViewportContainer/SubViewport/Camera2D

var Radius:int = 30 : #block
	set(new):
		Radius = new
		_world_update()
var Block_size:int = 50: #pix
	set(new):
		Block_size = new
		_world_update()

func _world_update()->void :
	var r:int = Radius * 2 * Block_size # edge
	camera.offset = Vector2(r,r)/2
	world.position = Vector2(r,r) / 2
	world.scale = Vector2.ONE * (r/512.0)
	
enum {IORN, COPPER, LUMIUM, STONE, COAL}
const colors = {
	IORN: Color(0.5, 0.5, 0.5, 1),
	COPPER: Color(0.682353, 0.368627, 0.243137, 1),
	LUMIUM: Color(0.0470588, 0.521569, 0.6, 1),
	STONE: Color(0.517647, 0.388235, 0.345098, 1),
	COAL: Color(0.1, 0.1, 0.1, 1)
}


func _set_color():
	const Iorn = Color(0.5, 0.5, 0.5)
	const Copper = Color(0.682353, 0.368627, 0.243137)
	const Lumium = Color(0.0470588, 0.521569, 0.6)
	const Stone = Color(0.517647, 0.388235, 0.345098)
	const Coal = Color(0.1, 0.1, 0.1)
	world.material.set_shader_parameter("Iorn", Iorn)
	world.material.set_shader_parameter("Copper", Copper)
	world.material.set_shader_parameter("Lumium", Lumium)
	world.material.set_shader_parameter("Stone", Stone)
	world.material.set_shader_parameter("Coal", Coal)

func _ready():
	var radius = $Control/Panel/VBoxContainer/Radius
	var block_size = $Control/Panel/VBoxContainer/BlockSize
	radius.value = Radius
	block_size.value = Block_size
	_world_update()
	_set_color()
func _on_radius_value_changed(value):
	Radius = value
func _on_block_size_value_changed(value):
	Block_size = value
func _on_save_button_down(): # SAVE MAP
	var data = _map_data_gen()
	data.test = 13
	# 使用 ResourceSaver 保存资源
	var error = ResourceSaver.save(data, "res://save_map.tres",0)
	if error == OK:
		print("Resource saved successfully!")
	else:
		print("Failed to save resource: ", error)
	
	
	print("saved!")
func _input(event):
	if event.is_action("zoom_in"):
		camera.zoom *= 1.05
	elif event.is_action("zoom_out"):
		camera.zoom *= 0.95
func _process(delta):
	camera.position += Input.get_vector("a", "d", "w", "s")*delta*200

func _get_img()-> Image:
	
	var r:int = Radius * 2 * Block_size # edge
	
	camera.offset = Vector2(r,r)/2
	camera.position = Vector2.ZERO
	camera.zoom = Vector2.ONE
	
	world.position = Vector2(r,r) / 2
	world.scale = Vector2.ONE * (r/512.0)
	
	viewport.size = Vector2(r,r)
	
	return viewport.get_texture().get_image()
	
func _img_to_polygon(img:Image)-> Array[Polygon]:
	var arr:Array[Polygon] = []
	for i in colors.keys():
		var bitmap = BitMap.new()
		bitmap.create(img.get_size())
		
		for x in range(img.get_size().x):
			for y in range(img.get_size().y):
				#print(img.get_pixel(x,y), " and ", colors[i])
				if img.get_pixel(x,y).to_abgr32() == colors[i].to_abgr32():
					#print("true")
					bitmap.set_bit(x, y, true)
		
		var poly = Polygon.new()
		poly.type = i
		poly.polygon = bitmap.opaque_to_polygons(Rect2(Vector2(), bitmap.get_size()), 0.1 )
		arr.append(poly)
	return arr

func _map_data_gen()-> Map_data:
	var r:int = (Radius * 2) * Block_size
	_get_img()
	var map_img:Image = _get_img()
	var map_data:Map_data = Map_data.new()
	
	
	var center:Vector2 = Vector2(r, r)/2
	
	for x:int in range(Radius * 2):
		for y:int in range(Radius * 2):
			var pos:Vector2 = Vector2(x,y) * Block_size
			#if (pos - center).length() > (r/2): continue # 截斷
			
			# 填充block
			var block:Block_data = Block_data.new()
			var rect:Rect2i = Rect2i(pos, Vector2(Block_size, Block_size) )
			block.pos = pos
			block.polygons = _img_to_polygon( map_img.get_region(rect) )
			
			
			map_data.blocks.append(block)
			print("block(", x,",", y, ") saved!")
	map_img.save_png("check.png")
	return map_data
