class_name command_context extends Area2D


@export var context = command_manager.commands.MINE


func _ready() -> void:
	collision_layer = 2
	collision_mask = 0
