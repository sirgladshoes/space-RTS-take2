extends Node2D

var networked_objects = []

var timer = Timer.new()

@export var command_giver: command_manager

var teams = {}

@export var master_template: master_unit_template

func _ready() -> void:
	timer.autostart = true
	timer.wait_time = 0.1
	timer.timeout.connect(send_world_state)
	add_child(timer)
	
	Network.recieved_client_command.connect(give_client_command)
	Network.make_unit.connect(make_unit)
	Network.client_connected_.connect(client_connected)

func send_world_state():
	#temperary
	if !Network.is_hosting:
		return
	
	Network.send_world_state()

func client_connected(id: int):
	Network.assign_team(id, selectable.teams.RED)
	teams[id] = selectable.teams.RED

func give_client_command(from, to, unit_ids, sender):
	var units = []
	for unit_id in unit_ids:
		if !Network.networked_objects.has(unit_id):
			continue
		var networked_obj = Network.networked_objects[unit_id]
		var unit = networked_obj.get_related_node("selectable")
		if unit.team != teams[sender]:
			print("potential cheater")
			continue
		units.append(unit)
	command_giver.give_command(from, to, units, teams[sender])

func make_unit(template_indx: int, maker_id: int):
	Network.networked_objects[maker_id].owner.make_unit(template_indx)

#remove later
func _on_join_pressed() -> void:
	queue_free()


func _on_host_pressed() -> void:
	Network.start_hosting(Network.PORT, 2)
