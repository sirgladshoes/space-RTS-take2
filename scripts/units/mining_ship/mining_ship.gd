extends Node2D

@export var move_speed: int = 100
@export var target_range: int = 100
@export var team: selectable.teams

var target_position: Vector2
var target_mineable: Node

var inventory = {"temp": 0}
@onready var sm = $state_machine
@onready var my_selectable = $selectable

func _ready() -> void:
	sm.set_transition_func(state_transitions)
	my_selectable.team = team

func _physics_process(delta: float) -> void:
	match sm.current_state:
		"travel":
			global_position = global_position.move_toward(target_position, move_speed*delta)
		"travel_mine":
			global_position = global_position.move_toward(target_mineable.global_position, move_speed*delta)
		"mine":
			inventory.temp += delta

func state_transitions(current: String):
	match current:
		"travel_mine":
			var target_pos = target_mineable.global_position
			if global_position.distance_to(target_pos) <= target_range:
				return "mine"
		"mine":
			var target_pos = target_mineable.global_position
			if global_position.distance_to(target_pos) > target_range:
				return "travel_mine"

func command_given(command: Variant, args: Variant) -> void:
	match command:
		command_manager.commands.MOVE:
			target_position = args[0]
			sm.switch_state("travel")
		command_manager.commands.MINE:
			target_mineable = args[0]
			sm.switch_state("travel_mine")
		command_manager.commands.TRANSFER_INVENTORY:
			var reciever = args[0].owner
			for type in inventory:
				reciever.inventory[type] += inventory[type]
				inventory[type] = 0
