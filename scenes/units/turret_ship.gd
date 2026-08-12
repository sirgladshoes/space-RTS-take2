extends Node2D

@export var move_speed: int = 100
@export var target_range: int = 200
@export var team: selectable.teams

var target_position: Vector2
var target_objects: Array
var current_target: Node

@onready var sm = $state_machine
@onready var my_selectable = $selectable

func _ready() -> void:
	sm.set_transition_func(state_transitions)
	my_selectable.team = team
	sm.switch_state("idle")
	$turret.max_range = target_range

func _process(delta: float) -> void:
	$team.frame = 2+$selectable.team

func _physics_process(delta: float) -> void:
	decide_target()
	match sm.current_state:
		"travel":
			rotation = rotate_toward(rotation, global_position.angle_to_point(target_position), 0.1)
			global_position = global_position.move_toward(target_position, move_speed*delta)
		"travel_attack":
			rotation = rotate_toward(rotation, global_position.angle_to_point(current_target.global_position), 0.1)
			global_position = global_position.move_toward(current_target.global_position, move_speed*delta)
		"attack":
			rotation = rotate_toward(rotation, global_position.angle_to_point(current_target.global_position), 0.1)

func state_transitions(current: String):
	if target_objects:
		decide_target()
	match current:
		"travel":
			if global_position.distance_to(target_position) <= 10:
				return "idle"
		"travel_attack":
			if !current_target:
				return "idle"
			var target_pos = current_target.global_position
			if global_position.distance_to(target_pos) <= target_range:
				return "attack"
		"attack":
			if !current_target:
				return "idle"
			var target_pos = current_target.global_position
			if global_position.distance_to(target_pos) > target_range:
				return "travel_attack"

func command_given(command: Variant, args: Variant) -> void:
	match command:
		command_manager.commands.MOVE:
			target_position = args[0]
			sm.switch_state("travel")
		command_manager.commands.ATTACK:
			target_objects = args
			decide_target()
			sm.switch_state("travel_attack")

func decide_target():
	for obj in target_objects:
		if !is_instance_valid(obj):
			target_objects.erase(obj)
	if !target_objects:
		current_target = null
		if sm.current_state != "travel":
			sm.switch_state("idle")
		return
	target_objects.sort_custom(distance_sort)
	current_target = target_objects[0]

func distance_sort(a, b):
	return global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position)
