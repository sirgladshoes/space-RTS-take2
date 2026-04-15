@tool
extends RayCast2D

@export var color: Color
@export var mask: int
@export var max_length: int = 100

@export var active: bool: set = set_active

var target: Node = null

signal hit_target(target: Node)

func _physics_process(delta: float) -> void:
	$Line2D.default_color = color
	target_position.x = max_length
	collision_mask = mask
	
	force_raycast_update()
	var length = target_position.x
	if is_colliding():
		hit_target.emit(get_collider())
		length = get_collision_point().distance_to(global_position)
	$Line2D.points[1] = Vector2(length, 0)

func set_active(value: bool):
	if active == value:
		return
	active = value
	
	set_physics_process(value)
	if !active:
		target_position = Vector2(0, 0)
	enabled = active
	visible = active
