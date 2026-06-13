extends Node2D


# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#if !Network.is_hosting:
		#get_node("game_host").queue_free()
		#Network.send_client_loaded()
	#else:
		#get_node("game_client").queue_free()
