class_name FPS
extends Label
func _process(delta):
	var fps = Performance.get_monitor(Performance.TIME_FPS)
	text = "fps" + str(fps)
	
	
	
