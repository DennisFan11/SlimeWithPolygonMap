class_name Map_node
extends Node2D

var Map_size:Vector2i
var BlockSize:Vector2i
@onready var Block_node:Node2D = $Building #$NavigationRegion2D/CanvasGroup #  
@onready var Building_node:Node2D = $Building

func _ready():
	_load()
	$NavigationRegion2D.bake_navigation_polygon(true)
#func get_blocks(global_pos:Vector2i)-> Array[Block]: # 委派
	#return data.get_blocks(global_pos)


var data:Map_data
func _load()-> void:
	data = ResourceLoader.load("res://save_map.tres", "Map_data")
	print("code: ", data.test_value) # 13 = ok
	
	Block_node.add_child(data.full_load())
	
	Map_size = data.Map_size
	BlockSize = data.BlockSize
	Global.GravityCenter = (Vector2(Map_size)/2.0)*Vector2(BlockSize)
func _save()-> void: #FIXME
	pass


var time:float = 50.0
func _physics_process(delta):
	time+= delta
	if time >= 20:
		$NavigationRegion2D.bake_navigation_polygon(true)
		


func _on_navigation_region_2d_bake_finished():
	print("bake_navigation !!!")
	time = 0.0
