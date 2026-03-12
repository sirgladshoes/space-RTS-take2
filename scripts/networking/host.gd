extends Node2D

var networked_objects = []

var timer = Timer.new()

@export var command_giver: command_manager


func _ready() -> void:

	timer.autostart = true
	timer.wait_time = 0.1
	timer.timeout.connect(send_game_state)
	add_child(timer)
	
	Network.recieved_client_command.connect(give_client_command)

func send_game_state():
	#temperary
	if !multiplayer.get_peers() or !multiplayer.is_server():
		return
	
	Network.send_game_state()



func give_client_command(from, to, unit_ids):
	var units = []
	for unit_id in unit_ids:
		var networked_obj = Network.networked_objects[unit_id]
		units.append(networked_obj.get_related_node("unit"))
	command_giver.give_command(from, to, units)


#remove later
func _on_join_pressed() -> void:
	queue_free()


func _on_host_pressed() -> void:
	Network.start_hosting(Network.PORT, 2)
