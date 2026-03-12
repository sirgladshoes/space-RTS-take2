extends Node2D


@export var command_giver: command_manager

func _ready() -> void:
	#temperary
	command_giver.command_given_raw.connect(send_command)

#two possible solutions: create player node that stores selected units, or find the the networking node
func send_command(from: Vector2, to:Vector2, units:Array):
	var object_ids = []
	for item in units:
		for child in item.owner.get_children():
			if child is networked_object:
				
			var id = item.owner
			#if id >= 0:
				#object_ids.append(id)
			#else:
				#printerr("object id not found")
	#
	#Network.send_client_command(from, to, object_ids)

#remove later
func _on_host_pressed() -> void:
	queue_free()


func _on_join_pressed() -> void:
	Network.connect_to_host("127.0.0.1", Network.PORT)
