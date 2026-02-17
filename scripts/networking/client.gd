extends Node2D

var networked_objects = {}

@export var command_giver: command_manager
#temporary
@export var test_ship: Node

func _ready() -> void:
	#temperary
	var networked_id = networked_type.networked_ids.MINING_SHIP
	networked_objects[0] = [networked_id, test_ship]
	
	Network.recieved_game_state.connect(construct_game_state)
	command_giver.command_given_raw.connect(send_command)

func object_id_from_object(object:Node) -> int:
	for id in networked_objects:
		if networked_objects[id][1] == object:
			return id
	return -1

func construct_game_state(state: Dictionary):
	for object_id in state:
		var networked_id = state[object_id][0]
		var object_state = state[object_id][1]
		var object = networked_objects[object_id][1]
		object.global_position.x = object_state.x
		object.global_position.y = object_state.y

func send_command(from: Vector2, to:Vector2, units:Array):
	var object_ids = []
	for item in units:
		print(item)
		var id = object_id_from_object(item.owner)
		if id >= 0:
			object_ids.append(id)
		else:
			printerr("object id not found")
	
	Network.send_client_command(from, to, object_ids)

#remove later
func _on_host_pressed() -> void:
	queue_free()
