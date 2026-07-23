extends Node2D

@export var team: selectable.teams



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_rotation = $turret.global_rotation
	$turret.rotation = 0
	$turret.team = team
	$selectable.team = team
	$team.frame = team+1
