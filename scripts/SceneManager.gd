extends Node

var current_scene = null

func load_menu():
	current_scene.queue_free()
	var scene = load("res://scenes/major/join_menu.tscn").instantiate()
	current_scene = scene
	get_tree().get_root().add_child(scene)

func load_lobby():
	current_scene.queue_free()
	var scene = load("res://scenes/major/lobby.tscn").instantiate()
	current_scene = scene
	get_tree().get_root().add_child(scene)

func load_game(teams: Dictionary):
	current_scene.queue_free()
	var scene = load("res://scenes/major/game.tscn").instantiate()
	current_scene = scene
	get_tree().get_root().add_child(scene)
	if teams.has(1):
		scene.get_node("game_host").teams = teams
		scene.get_node("command_manager").team = teams[1] as selectable.teams
