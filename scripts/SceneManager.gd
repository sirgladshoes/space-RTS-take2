extends Node

var current_scene = null



func load_lobby():
	current_scene.queue_free()
	var scene = load("res://scenes/major/lobby.tscn").instantiate()
	get_tree().get_root().add_child(scene)

func load_game():
	current_scene.queue_free()
	var scene = load("res://scenes/major/game.tscn").instantiate()
	get_tree().get_root().add_child(scene)
