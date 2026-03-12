extends Node2D


@export var command_giver: command_manager

func _ready() -> void:
	#temperary
	command_giver.command_given_raw.connect(send_command)


func send_command(from: Vector2, to:Vector2, units:Array):
	var object_ids = []
	for item in units:
		if !item.has_meta("networked_object"):
			continue
		
		var networked_obj = item.get_meta("networked_object")
		if networked_obj:
			object_ids.append(networked_obj.object_id)

	
	Network.send_client_command(from, to, object_ids)

#remove later
func _on_host_pressed() -> void:
	queue_free()


func _on_join_pressed() -> void:
	Network.connect_to_host("127.0.0.1", Network.PORT)
