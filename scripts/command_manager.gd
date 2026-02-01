extends Node2D

@export var selection_width: int = 1

var select_origin = null

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("select"):
		select_origin = get_global_mouse_position()
	elif event.is_action_released("select"):
		var mouse_pos = get_global_mouse_position()
		
		var shape_query = PhysicsShapeQueryParameters2D.new()
		var rect = RectangleShape2D.new()
		
		rect.set_size((mouse_pos-select_origin).abs())
		shape_query.transform = Transform2D(0, select_origin+(mouse_pos-select_origin)/2)
		shape_query.set_shape(rect) 
		
		var physics_state = get_world_2d().direct_space_state
		var result = physics_state.intersect_shape(shape_query)
		print(result)
		select_origin = null

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	if select_origin:
		var mouse = get_global_mouse_position()
		var rect = Rect2(select_origin, mouse-select_origin)
		var color = Color(0.107, 0.453, 0.48, 0.6)
		draw_rect(rect, color, false, selection_width)
