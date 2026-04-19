extends Node2D

@export var move_speed: int = 100
@export var target_range: int = 200
@export var team: selectable.teams

var target_position: Vector2
var target_object: Node

@onready var sm = $state_machine
@onready var my_selectable = $selectable
@onready var my_inventory = $inventory

func _ready() -> void:
	sm.set_transition_func(state_transitions)
	my_selectable.team = team
	sm.switch_state("idle")

func _process(delta: float) -> void:
	$team.frame = 2+$selectable.team

func _physics_process(delta: float) -> void:
	match sm.current_state:
		"travel":
			rotation = rotate_toward(rotation, global_position.angle_to_point(target_position), 0.1)
			global_position = global_position.move_toward(target_position, move_speed*delta)
		"travel_mine":
			rotation = rotate_toward(rotation, global_position.angle_to_point(target_object.global_position), 0.1)
			global_position = global_position.move_toward(target_object.global_position, move_speed*delta)
		"mine":
			rotation = rotate_toward(rotation, global_position.angle_to_point(target_object.global_position), 0.1)
		"travel_transfer":
			rotation = rotate_toward(rotation, global_position.angle_to_point(target_object.global_position), 0.1)
			global_position = global_position.move_toward(target_object.global_position, move_speed*delta)

func state_transitions(current: String):
	match current:
		"travel":
			if global_position.distance_to(target_position) <= 10:
				return "idle"
		"travel_mine":
			var target_pos = target_object.global_position
			if global_position.distance_to(target_pos) <= target_range:
				return "mine"
		"mine":
			var target_pos = target_object.global_position
			if global_position.distance_to(target_pos) > target_range:
				return "travel_mine"
		"travel_transfer":
			var target_pos = target_object.global_position
			if global_position.distance_to(target_pos) <= target_range:
				return "idle"

func command_given(command: Variant, args: Variant) -> void:
	match command:
		command_manager.commands.MOVE:
			target_position = args[0]
			sm.switch_state("travel")
		command_manager.commands.MINE:
			target_object = args[0]
			sm.switch_state("travel_mine")
		command_manager.commands.TRANSFER_INVENTORY:
			target_object = args[0] 
			sm.switch_state("travel_transfer")


func _on_state_machine_state_switched(current: String, previous: String) -> void:
	if current == "idle" and previous == "travel_transfer":
		var target = target_object.connected_nodes.inventory
		for resource in inventory.resource_types.values():
			target.add_resource(resource, my_inventory.remove_all_resource(resource))
	if current == "mine":
		$mining_laser.active = true
	if previous == "mine":
		$mining_laser.active = false


func _on_mining_laser_hit_object(object: Node) -> void:
	my_inventory.add_resource(inventory.resource_types.TEMP, 1)
