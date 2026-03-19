class_name selectable extends Area2D

enum teams {
	BLUE,
	RED
}

@export var team: teams = teams.BLUE
@export var display_data: Dictionary[StringName, Variant] = {"name":"default name"}

signal on_selected()
signal command_given(command: int, args: Array)

func _ready() -> void:
	monitoring = false
	collision_mask = 0
	collision_layer = 1

func selected():
	on_selected.emit()

func give_command(command: int, args: Array):
	command_given.emit(command, args)
