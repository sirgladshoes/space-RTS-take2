extends Node2D

@export var team: selectable.teams
 
var target_position: Vector2

func _ready() -> void:
	$selectable.team = team

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("test"):
		var scene = load("res://scenes/units/mining_ship.tscn")
		var node = scene.instantiate()
		node.global_position = $Marker2D.global_position
		owner.add_child(node)

func _physics_process(delta: float) -> void:
	if target_position:
		global_position = global_position.move_toward(target_position, 100*delta)
		look_at(target_position)

func _on_selectable_command_given(command: int, args: Array) -> void:
	match command:
		command_manager.commands.MOVE:
			target_position = args[0]
