extends Node2D
###ver 0.01 (方案一) 多邊形地圖生成





func _process(delta):
	%camera.position += Input.get_vector("a", "d", "w", "s")*delta*600
func _input(event):
	if event.is_action("zoom_in"):
		%camera.zoom *= 1.05
	elif event.is_action("zoom_out"):
		%camera.zoom *= 0.95
