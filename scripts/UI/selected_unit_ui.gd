extends Control

var my_unit: selectable

signal focus_pressed(unit)
signal deselect_pressed(unit)

func _process(_delta: float) -> void:
	update_data(my_unit)

func update_data(unit: selectable):
	$name.text = unit.display_data.name
	if unit.display_data.has("inventory"):
		var inventory_ = unit.get_node(unit.display_data.inventory)
		var resources = inventory_.get_all_resources()
		for resource in resources:
			$inventory.get_node(resource+"/count").text = str(resources[resource])


func _on_focus_button_pressed() -> void:
	focus_pressed.emit(my_unit)


func _on_deselect_button_pressed() -> void:
	deselect_pressed.emit(my_unit)
