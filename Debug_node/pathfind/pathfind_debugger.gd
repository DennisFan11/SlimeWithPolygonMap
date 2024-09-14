extends Node2D
func _process(delta: float) -> void:
	$NavigationAgent2D.get_next_path_position()
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		get_viewport().set_input_as_handled()
		global_position = get_global_mouse_position()


func _on_timer_timeout() -> void:
	$NavigationAgent2D.target_position = get_global_mouse_position()
