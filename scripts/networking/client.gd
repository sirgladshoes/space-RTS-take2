extends Node2D


@export var command_giver: command_manager

func _ready() -> void:
	#temperary
	command_giver.command_given_raw.connect(send_command)
	Network.create_object.connect(create_networked_object)
	Network.assigned_team.connect(assigned_team)


func send_command(from: Vector2, to:Vector2, units:Array) -> void:
	var object_ids = []
	for item in units:
		if !item.has_meta("networked_object"):
			continue
		
		var networked_obj = item.get_meta("networked_object")
		if networked_obj:
			object_ids.append(networked_obj.object_id)
	
	Network.send_client_command(from, to, object_ids)

func create_networked_object(object: Node) -> void:
	owner.add_child(object)

func assigned_team(team: int) -> void:
	command_giver.team = team as selectable.teams

#remove later
func _on_host_pressed() -> void:
	queue_free()

func _on_join_pressed() -> void:
	Network.connect_to_host("127.0.0.1", Network.PORT)
