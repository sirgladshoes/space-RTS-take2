extends Control

@export var networked_obj: networked_object
@export var master_template: master_unit_template
@export var linked_inventory: inventory

func _ready() -> void:
	var children = $ScrollContainer/VBoxContainer.get_children()
	for i in range(master_template.data.size()):
		var cost = master_template.data[i].cost
		for resource in cost:
			children[i].get_node(str(resource)+"/Label").text = str(cost[resource])

func _process(delta: float) -> void:
	var children = $ScrollContainer/VBoxContainer.get_children()
	for i in range(master_template.data.size()):
		var cost = master_template.data[i].cost
		children[i].get_node("button").disabled = false
		for resource in cost:
			if linked_inventory.get_resource_amount(resource) < cost[resource]:
				children[i].get_node("button").disabled = true
				break

func make_unit(indx: int) -> void:
	#kinda hacky, but it works
	Network.rpc_id(1, "recv_make_unit", indx, networked_obj.object_id)


#mining_ship
func _on_texture_button_pressed() -> void:
	make_unit(0)


func _on_attack_ship_texture_button_pressed() -> void:
	make_unit(1)


func _on_turret_ship_texture_button_pressed() -> void:
	make_unit(2)
