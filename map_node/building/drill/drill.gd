extends Node2D

enum {PREVIEW,BLUEPRINT,BUILDING,FINISH,DELETE}


var Stat:int = -1

var BodyArea2D:Area2D
var LandingGearL:Area2D
var LandingGearR:Area2D

func Set_stat(new_stat:int):
	Stat = new_stat
func Set_BodyArea2D(Area:Area2D):
	BodyArea2D = Area
func Set_LandingGears(AreaL:Area2D, AreaR:Area2D):
	LandingGearL = AreaL
	LandingGearR = AreaR

func _ready():
	Set_BodyArea2D($BodyArea2D)
	Set_LandingGears($LandingGearL,$LandingGearR)
	Set_stat(PREVIEW)

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
func _can_build()-> bool: # 能否建築 依賴於3個Area
	
	if BodyArea2D.get_overlapping_bodies().size() != 0:
		return false
	var L = false
	var R = false
	for i in LandingGearL.get_overlapping_bodies():
		if i.is_in_group("Block"):
			L = true
	for i in LandingGearR.get_overlapping_bodies():
		if i.is_in_group("Block"):
			R = true
	return L and R

func _unhandled_input(event):
	if event.is_action_pressed("click"): # 移動至下一狀態
		if Stat == PREVIEW and _can_build():
			$Terrain_scanner.queue_free()
			Set_stat(FINISH) # FIXME 測試階段跳過(BLUEPRINT & BUILDING) Stat+1



# -------------------偵更新 回調函數

func _PREVIEW():
	var point = $Terrain_scanner.Get_closest_point()
	if point == Vector2.ZERO:
		point = get_global_mouse_position()+Vector2(0.0,1.0)
	global_position = point
	rotation = (point - get_global_mouse_position()).angle()-PI/2
	
func _BLUEPRINT():
	pass
func _BUILDING():
	pass
func _FINISH():
	pass
func _DELETE():
	pass
