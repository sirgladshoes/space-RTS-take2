extends Node2D

@export var asteroid_scene: PackedScene


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MusicManager.start_shuffle()
	
	if !Network.is_hosting:
		Network.win_screen.connect(win_screen)
		get_node("game_host").queue_free()
		Network.send_client_loaded()
	else:
		get_node("game_client").queue_free()


func _on_asteroid_timeout() -> void:
	if !Network.is_hosting:
		return
	var scene = asteroid_scene.instantiate()
	add_child(scene)
	$event_timers/asteroid.start()

func win_screen(winning_team):
	MusicManager.end_shuffle()
	
	if winning_team == 1:
		$bteam_wins.visible = true
	else:
		$rteam_wins.visible = true

func _exit_tree() -> void:
	Network.object_id_counter = 0
