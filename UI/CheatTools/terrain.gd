extends Control


enum {CIRCLE, SQUARE, CIRCLE_LINE, SQUARE_LINE}

var file = preload("res://game/weapon/TerrainEditer/terrain_editer.tscn")
var node = null

var Shape:int = CIRCLE
var R = 70.0
var Block_ID:int = 0
var Expand:bool = false
var Line:bool = false
func _update():
	if !node:
		node = file.instantiate()
		Global.ToolNode.add_child(node)
	node.R = R
	node.Expand = Expand
	node.Block_ID = Block_ID
	if Line == false:
		node.Shape = Shape
	else:
		node.Shape = Shape+2
#func _ready():
	#_update()
#func _on_circle_button_down():
	#node.Shape = CIRCLE
	#_update()
#func _on_square_button_down():
	#node.Shape = SQUARE
	#_update()
func _on_line_toggled(toggled_on):
	Line = toggled_on
	_update()
func _on_expand_toggled(toggled_on):
	Expand = toggled_on
	_update()
func _on_id_value_changed(value):
	Block_ID = value
	_update()
func _on_r_value_changed(value):
	R = value
	_update()


func _on_circle_pressed():
	Shape = CIRCLE
	_update()


func _on_square_pressed():
	Shape = SQUARE
	_update()
