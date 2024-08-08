extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



func _process(delta):
	%camera.position += Input.get_vector("a", "d", "w", "s")*delta*600
func _input(event):
	if event.is_action("zoom_in"):
		%camera.zoom *= 1.05
	elif event.is_action("zoom_out"):
		%camera.zoom *= 0.95
