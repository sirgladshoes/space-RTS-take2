extends Control

var selected_units: Array[Node] = []

@onready var my_command_manager = get_parent()
@onready var selected_unit_scene = load("res://scenes/command_ui/selected_unit.tscn")

func show_selected(selected_units_):
	for unit in selected_units:
		unit.queue_free()
	selected_units = []
	selected_units_.sort_custom(sort_by_name)
	if selected_units_:
		for unit in selected_units_:
			var node = selected_unit_scene.instantiate()
			node.my_unit = unit
			node.focus_pressed.connect(my_command_manager.focus_unit)
			node.deselect_pressed.connect(my_command_manager.deselect_unit)
			selected_units.append(node)
			$selected_units/VBoxContainer.add_child(node)
		
		visible = true
	else:
		visible = false

func sort_by_name(a, b):
	return a.display_data.name < b.display_data.name
