extends Node2D

@export var move_speed: int = 100
@export var target_range: int = 100

var target_position: Vector2
var target_mineable: Node

var inventory = {"temp": 0}



func _physics_process(delta: float) -> void:
	#given mine command
	if target_mineable:
		var target_pos = target_mineable.global_position
		
		if global_position.distance_to(target_pos) > target_range:
			global_position = global_position.move_toward(target_pos, move_speed*delta)
		else:
			inventory.temp += delta
	
	#given move command
	if target_position:
		global_position = global_position.move_toward(target_position, move_speed*delta)


func command_given(command: Variant, args: Variant) -> void:
	target_position = Vector2.ZERO
	target_mineable = null
	match command:
		command_manager.commands.MOVE:
			target_position = args[0]
		command_manager.commands.MINE:
			target_mineable = args[0]
