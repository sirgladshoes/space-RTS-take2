class_name command_manager extends Node2D

@export var selection_width: int = 1

var select_origin = null
var selected_units = []

var command_origin = null

enum commands{
	MOVE,
	MINE, 
	ATTACK
}

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("select"):
		select_origin = get_global_mouse_position()
	elif event.is_action_released("select"):
		select_units(select_origin, get_global_mouse_position())
	elif event.is_action_pressed("command"):
		if selected_units:
			command_origin = get_global_mouse_position()
	elif event.is_action_released("command"):
		#only gives command if there is a selection origin
		if command_origin:
			if multiplayer.is_server():
				give_command(command_origin, get_global_mouse_position(), selected_units)
			else:
				Network.send_client_command(command_origin, get_global_mouse_position(), selected_units)
			command_origin = null

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	if select_origin:
		var mouse = get_global_mouse_position()
		var rect = Rect2(select_origin, mouse-select_origin)
		var color = Color(0.107, 0.453, 0.48, 0.6)
		draw_rect(rect, color, false, selection_width)
	if command_origin:
		var mouse = get_global_mouse_position()
		var rect = Rect2(command_origin, mouse-command_origin)
		var color = Color(0.106, 0.769, 0.184, 0.6)
		draw_rect(rect, color, false, selection_width)

func rect_cast(size: Vector2, center: Vector2, mask: int) -> Array:
	var shape_query = PhysicsShapeQueryParameters2D.new()
	var rect = RectangleShape2D.new()
	
	shape_query.collision_mask = mask
	shape_query.set_collide_with_areas(true)
	
	rect.set_size(size)
	shape_query.transform = Transform2D(0, center)
	shape_query.set_shape(rect) 
	
	var physics_state = get_world_2d().direct_space_state
	var result = physics_state.intersect_shape(shape_query)
	
	return result

func select_units(from: Vector2, to: Vector2):
	var size = (to-from).abs()
	var command_center = from+(to-from)/2
	var result = rect_cast(size, command_center, 1)
	
	select_origin = null
	
	selected_units = []
	if result:
		for item in result:
			var unit = item.collider
			selected_units.append(unit)
			if unit is selectable:
				unit.selected()

func give_command(from: Vector2, to: Vector2, units: Array): 
	var size = (to-from).abs()
	var command_center = from+(to-from)/2
	var result = rect_cast(size, command_center, 2)
	
	#begin command logic
	var command = commands.MOVE
	if result and result[0].collider is command_context:
		command = result[0].collider.context
	
	var args = []
	match command:
		commands.MOVE:
			args.append(command_center)
		commands.MINE:
			args.append(result[0].collider)
	
	for item in units:
		item.command_given(command, args)
