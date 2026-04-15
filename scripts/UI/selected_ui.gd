class_name selected_ui extends Control

@export var my_inventory: inventory

func _ready() -> void:
	z_as_relative = false
	z_index = 1000
	visible = false

func selected():
	visible = true

func deselected():
	visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotation = -owner.rotation
	if my_inventory:
		var resources = my_inventory.get_all_resources()
		for resource in resources:
			$inventory.get_node(resource+"/count").text = str(resources[resource])
