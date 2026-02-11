class_name selectable extends Area2D


signal on_selected()
signal on_command_given(command, args)

func _ready() -> void:
	collision_mask = 0
	collision_layer = 1

func selected():
	on_selected.emit()

func command_given(command: int, args: Array):
	on_command_given.emit(command, args)
