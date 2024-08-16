class_name Main_game
extends Node2D
###ver 0.02 (方案二) 方塊地圖生成

func _ready(): 
	Global.MainGame = self
	Global.MapNode = $Map_node








func _process(delta):
	if on:
		%camera.position += Input.get_vector("a", "d", "w", "s")*delta*600
var on:bool = false
@onready var player_camera := get_viewport().get_camera_2d()
func _input(event):
	if event.is_action("zoom_in"):
		%camera.zoom *= 1.05
	elif event.is_action("zoom_out"):
		%camera.zoom *= 0.95
	elif event.is_action_pressed("*"):
		on = !on
		%camera.enabled = on
		player_camera.enabled = !on
		print("Camera : ", on)
