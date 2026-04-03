class_name command_manager extends Node2D

@export var selection_width: int = 1

var select_origin = null
var selected_units: Array[selectable] = []

var command_origin = null
var team: selectable.teams = selectable.teams.BLUE

enum commands{
	MOVE,
	ATTACK,
	MINE, 
	TRANSFER_INVENTORY
}

signal command_given_raw(from: Vector2, to: Vector2, units: Array)
signal units_selected(units: Array)

func _unhandled_input(event: InputEvent) -> void:
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
			command_given_raw.emit(command_origin, get_global_mouse_position(), selected_units)
			if Network.is_hosting:
				give_command(command_origin, get_global_mouse_position(), selected_units, team)
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
	
	for unit in selected_units:
		unit.deselected()
	selected_units = []
	if result:
		for item in result:
			var unit = item.collider
			if unit is selectable and unit.team == team:
				selected_units.append(unit)
				unit.selected()
	units_selected.emit(selected_units)

func focus_unit(unit: selectable):
	selected_units = [unit]
	unit.selected()
	units_selected.emit(selected_units)

func deselect_unit(unit: selectable):
	selected_units.erase(unit)
	units_selected.emit(selected_units)

func give_command(from: Vector2, to: Vector2, units: Array, commander_team:int): 
	var size = (to-from).abs()
	var command_center = from+(to-from)/2
	var result = rect_cast(size, command_center, 2)
	
	#begin command logic
	var command = commands.MOVE
	var context_objs: Array[command_context] = []
	var contexts: Array[commands] = []
	if result:
		for item in result:
			var object = item.collider
			if object is command_context:
				if object.context == commands.ATTACK and object.connected_nodes.selectable.team == commander_team:
					continue
				if object.context == commands.TRANSFER_INVENTORY and object.connected_nodes.selectable.team != commander_team:
					continue
				
				context_objs.append(object)
				contexts.append(object.context)
	
	for num in commands.values():
		if num in contexts:
			command = num
	
	var args = []
	match command:
		commands.MOVE:
			args.append(command_center)
		commands.MINE:
			for object in context_objs:
				if object.context == commands.MINE:
					args=[object]
		commands.ATTACK:
			for object in context_objs:
				if object.context == commands.ATTACK:
					args.append(object)
		commands.TRANSFER_INVENTORY:
			for object in context_objs:
				if object.context == commands.TRANSFER_INVENTORY:
					args=[object]
	
	for item in units:
		item.give_command(command, args)
