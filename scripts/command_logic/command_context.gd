class_name command_context extends Area2D


@export var context: command_manager.commands
@export var connected_nodes: Dictionary[StringName, Node]

func _ready() -> void:
	monitoring = false
	collision_layer = 2
	collision_mask = 0
