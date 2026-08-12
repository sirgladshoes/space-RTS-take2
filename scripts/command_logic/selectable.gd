class_name selectable extends Area2D

enum teams {
	BLUE,
	RED,
	ALIEN
}

@export var team: teams = teams.BLUE
@export var display_data: Dictionary[StringName, Variant] = {"name":"default name"}

signal on_selected()
signal on_deselected()
signal command_given(command: int, args: Array)

@onready var sfx_player = AudioStreamPlayer.new()

func _ready() -> void:
	monitoring = false
	collision_mask = 0
	collision_layer = 1
	
	sfx_player.stream = load("res://sfx/select.wav")
	sfx_player.set_bus("ui")
	add_child(sfx_player)

func selected():
	on_selected.emit()
	sfx_player.play()

func deselected():
	on_deselected.emit()

func give_command(command: int, args: Array):
	command_given.emit(command, args)
