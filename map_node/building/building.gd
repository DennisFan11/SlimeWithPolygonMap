class_name Building
extends Node2D

enum {PREVIEW,BLUEPRINT,BUILDING,FINISH,DELETE}


var Stat:int = -1

var Land_area:Area2D
var Colli_area:Area2D

func Set_stat(new_stat:int):
	Stat = new_stat
func Set_land_area(Area:Area2D):
	Land_area = Area
func Set_colli_area(Area:Area2D):
	Colli_area = Area



func _process(delta):
	match Stat:
		PREVIEW:
			_PREVIEW()
		BLUEPRINT:
			_BLUEPRINT()
		BUILDING:
			_BUILDING()
		FINISH:
			_FINISH()
		DELETE:
			_DELETE()
#--------------

# -------------------偵更新 回調函數

func _PREVIEW():
	global_position = get_global_mouse_position()
func _BLUEPRINT():
	pass
func _BUILDING():
	pass
func _FINISH():
	pass
func _DELETE():
	pass
