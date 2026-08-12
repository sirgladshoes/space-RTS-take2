@tool
extends Node2D

var targets = []
var current_target: Node
@export var team: selectable.teams

@export var max_range: int = 200

func _ready() -> void:
	$laser.max_length = max_range
	$Area2D/CollisionShape2D.shape.radius = max_range

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	$laser.max_length = max_range
	$Area2D/CollisionShape2D.shape.radius = max_range
	if owner and owner.has_node("selectable"):
		team = owner.get_node("selectable").team
	if $team.hframes*$team.vframes > team+1:
		$team.frame = team+1
	
	decide_target()
	if current_target:
		$laser.active = true
		look_at(current_target.global_position)
	else:
		$laser.active = false

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.context == command_manager.commands.ATTACK and area.connected_nodes.selectable.team != team:
		targets.append(area)

func _on_area_2d_area_exited(area: Area2D) -> void:
	if area in targets:
		targets.erase(area)

func distance_sort(a, b):
	return global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position)

func decide_target():
	for obj in targets:
		if !is_instance_valid(obj) or obj.connected_nodes.selectable.team == team:
			targets.erase(obj)
	if !targets:
		current_target = null
		return
	targets.sort_custom(distance_sort)
	current_target = targets[0]


func _on_laser_hit_object(object: Node) -> void:
	object.take_damage(1)
	$AudioStreamPlayer2D.play()
