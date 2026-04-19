@tool
extends RayCast2D

@export var color: Color
@export var mask: int
@export var max_length: int = 100
@export var hit_interval: float = 0.1

@export var active: bool: set = set_active

var hit_obj: Node = null

signal hit_object(object: Node)

func _ready() -> void:
	#I hate ts but we gotta do it
	active = !active
	active = !active
	collision_mask = mask

func _physics_process(_delta: float) -> void:
	$Timer.wait_time = hit_interval
	$Line2D.default_color = color
	target_position.x = max_length
	
	force_raycast_update()
	var length = target_position.x
	if is_colliding():
		var obj = get_collider()
		if obj != hit_obj:
			$Timer.start()
			hit_obj = obj
		length = get_collision_point().distance_to(global_position)
	else:
		if hit_obj:
			hit_obj = null
			$Timer.stop()
	$Line2D.points[1] = Vector2(length, 0)

func set_active(value: bool):
	if active == value:
		return
	active = value
	
	set_physics_process(value)
	if !active:
		hit_obj = null
		$Timer.stop()
		target_position = Vector2(0, 0)
	enabled = active
	visible = active


func _on_timer_timeout() -> void:
	if hit_obj:
		hit_object.emit(hit_obj)
