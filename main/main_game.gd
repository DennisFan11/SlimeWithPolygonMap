class_name Main_game
extends Node2D
###ver 0.02 (方案二) 方塊地圖生成

func _ready(): 
	Global.MainGame = self
	Global.MapNode = $Map_node
	Global.ParticleNode = $Particle_node
	Global.ToolNode = $ToolNode
	
	
	$test_node/Player.position.x = Global.GravityCenter.x
	$test_node/Player.position.y = -50#10020.0
	Global.GravityCenter.y += 999999999.0





func _process(delta):
	if on:
		%camera.position += Input.get_vector("left", "right", "up", "down")*delta*600
var on:bool = false
@onready var player_camera := get_viewport().get_camera_2d()
func _unhandled_input(event):
	if event.is_action("zoom_in"):
		%camera.zoom *= 1.05
	elif event.is_action("zoom_out"):
		%camera.zoom *= 0.95
	elif event.is_action_pressed("*"):
		on = !on
		%camera.enabled = on
		player_camera.enabled = !on
		print("Camera : ", on)
