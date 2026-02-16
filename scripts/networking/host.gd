extends Node2D

var networked_objects = {}
var object_id_counter = 0

var timer = Timer.new()

@export var command_giver: command_manager

#temporary
@export var test_ship: Node

func _ready() -> void:
	var networked_id = object_networking_data.networked_ids.MINING_SHIP
	test_ship.name = "0"
	add_networked_object(networked_id, test_ship)
	
	timer.autostart = true
	timer.wait_time = 0.05
	timer.timeout.connect(send_game_state)
	add_child(timer)
	
	Network.recieved_client_command.connect(give_client_command)
	#temperary
	Network.recieved_game_state.connect(construct_game_state)

func send_game_state():
	#temperary
	if !multiplayer.get_peers() or !multiplayer.is_server():
		return
	
	var state = {}
	for object_id in networked_objects:
		state[object_id] = [networked_objects[object_id][0] , object_state_from_id(object_id)]
	
	Network.send_game_state(state)

func object_state_from_id(object_id: int) -> Dictionary:
	var state = {}
	var networked_id = networked_objects[object_id][0]
	var node =  networked_objects[object_id][1]
	
	match networked_id:
		object_networking_data.networked_ids.MINING_SHIP:
			state["x"] = node.global_position.x
			state["y"] = node.global_position.y
			state["name"] = "test"
	
	return state

func add_networked_object(networked_id: int, object: Node) -> int:
	var object_id = object_id_counter
	networked_objects[object_id] = [networked_id, object]
	object_id_counter+=1
	return object_id


func give_client_command(from, to, unit_ids):
	
	var units = []
	for unit_id in unit_ids:
		units.append(networked_objects[unit_id][1])
	command_giver.give_command(from, to, units)


#move to client
func construct_game_state(state: Dictionary):
	for object_id in state:
		var networked_id = state[object_id][0]
		var object_state = state[object_id][1]
		var object = networked_objects[object_id][1]
		object.global_position.x = object_state.x
		object.global_position.y = object_state.y
