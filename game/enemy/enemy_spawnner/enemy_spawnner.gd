extends Node2D
var Scene = preload("res://game/enemy/enemy_01/enemy_01.tscn")
var time = 0.0
func _process(delta):
	time += delta
	if time >= 3:
		time = 0.0
		add_child(Scene.instantiate())
